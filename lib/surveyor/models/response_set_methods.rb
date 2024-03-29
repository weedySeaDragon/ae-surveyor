module Surveyor
  module Models
    module ResponseSetMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      included do

        # Associations
        belongs_to :survey
        belongs_to :user

        has_many :responses, -> { includes :answer }, :dependent => :destroy

        accepts_nested_attributes_for :responses, :allow_destroy => true
        attr_accessible *PermittedParams.new.response_set_attributes if defined? ActiveModel::MassAssignmentSecurity

        # Validations
        validates_presence_of :survey_id
        validates_associated :responses
        validates_uniqueness_of :access_code

        # Derived attributes
        before_create :ensure_start_timestamp
        before_create :ensure_identifiers
      end

      # ----------------------------------------------------------------------------------------------------------------

      module ClassMethods

        # FIXME params cannot use any? after Rails 5.1. Will no longer inherit from Hash
        def has_blank_value?(hash)
          return true if hash["answer_id"].blank?
          return false if (q = Question.find_by_id(hash["question_id"])) and q.pick == "one"
          hash.any? { |_k, v| v.is_a?(Array) ? v.all? { |x| x.to_s.blank? } : v.to_s.blank? } # hash value is an Array and the array is empty
        end
      end

      # ----------------------------------------------------------------------------------------------------------------

      def ensure_start_timestamp
        self.started_at ||= Time.now
      end

      def ensure_identifiers
        self.access_code ||= Surveyor::Common.make_tiny_code
        self.api_id ||= Surveyor::Common.generate_api_id
      end

      def to_csv(access_code = false, print_header = true)
        result = Surveyor::Common.csv_impl.generate do |csv|
          if print_header
            csv << (access_code ? ["response set access code"] : []) +
              csv_question_columns.map { |qcol| "question.#{qcol}" } +
              csv_answer_columns.map { |acol| "answer.#{acol}" } +
              csv_response_columns.map { |rcol| "response.#{rcol}" }
          end
          responses.each do |response|
            csv << (access_code ? [self.access_code] : []) +
              csv_question_columns.map { |qcol| response.question.send(qcol) } +
              csv_answer_columns.map { |acol| response.answer.send(acol) } +
              csv_response_columns.map { |rcol| response.send(rcol) }
          end
        end
        result
      end

      %w(question answer response).each do |model|
        define_method "csv_#{model}_columns" do
          model.capitalize.constantize.content_columns.map(&:name) - (model == "response" ? [] : %w(created_at updated_at))
        end
      end

      def as_json(options = nil)
        template_paths = ActionController::Base.view_paths.collect(&:to_path)
        Rabl.render(self, 'surveyor/show.json', :view_path => template_paths, :format => "hash")
      end

      def complete!
        self.completed_at = Time.now
      end

      def complete?
        !completed_at.nil?
      end

      def correct?
        responses.all?(&:correct?)
      end

      def correctness_hash
        { :questions => Survey.where(id: self.survey_id).includes(sections: :questions).first.sections.map(&:questions).flatten.compact.size,
          :responses => responses.compact.size,
          :correct => responses.find_all(&:correct?).compact.size
        }
      end

      def mandatory_questions_complete?
        progress_hash[:triggered_mandatory] == progress_hash[:triggered_mandatory_completed]
      end

      def progress_hash
        qs = Survey.where(id: self.survey_id).includes(sections: :questions).first.sections.map(&:questions).flatten
        ds = dependencies(qs.map(&:id))
        triggered = qs - ds.select { |d| !d.is_met?(self) }.map(&:question)
        { :questions => qs.compact.size,
          :triggered => triggered.compact.size,
          :triggered_mandatory => triggered.select { |q| q.mandatory? }.compact.size,
          :triggered_mandatory_completed => triggered.select { |q| q.mandatory? and is_answered?(q) }.compact.size
        }
      end

      def is_answered?(question)
        %w(label image).include?(question.display_type) or !is_unanswered?(question)
      end

      def is_unanswered?(question)
        self.responses.detect { |r| r.question_id == question.id }.nil?
      end

      def is_group_unanswered?(group)
        group.questions.any? { |question| is_unanswered?(question) }
      end

      # Returns the number of response groups (count of group responses enterted) for this question group
      def count_group_responses(questions)
        questions.map { |q|
          responses.select { |r|
            (r.question_id.to_i == q.id.to_i) && !r.response_group.nil?
          }.group_by(&:response_group).size
        }.max
      end

      def unanswered_dependencies
        unanswered_question_dependencies + unanswered_question_group_dependencies
      end

      def unanswered_question_dependencies
        dependencies.select { |d| d.question && self.is_unanswered?(d.question) && d.is_met?(self) }.map(&:question)
      end

      def unanswered_question_group_dependencies
        dependencies.
          select { |d| d.question_group && self.is_group_unanswered?(d.question_group) && d.is_met?(self) }.
          map(&:question_group)
      end

      def all_dependencies(question_ids = nil)
        arr = dependencies(question_ids).partition { |d| d.is_met?(self) }
        {
          :show => arr[0].map { |d| d.question_group_id.nil? ? "q_#{d.question_id}" : "g_#{d.question_group_id}" },
          :hide => arr[1].map { |d| d.question_group_id.nil? ? "q_#{d.question_id}" : "g_#{d.question_group_id}" }
          # :invalid => invalid_hash # :question_id => "message" - the questions which are invalid
        }
      end

      # Check existence of responses to questions from a given survey_section
      def no_responses_for_section?(section)
        !responses.any? { |r| r.survey_section_id == section.id }
      end


      # the surveryor_gui gem created an answer type: a grid of checkboxes where many checked boxes for 1 questions are allowed
      # ( = the grid answer types)
      # This can create invalid attribute paremeters (malformed) for a Response.
      # The answer_id can be set to an Array (!) in this case.
      # So must be able to handle that. (blech).  Will just take the last number in the Array if the answer_id => an Array
      #
      #  FIXME - change the params structure/shape
      def update_from_params(parameters)

        transaction do
          parameters.each do |ord, response_hash|
            api_id = response_hash['api_id']
            fail "api_id missing from response #{ord}" unless api_id

            existing = Response.where(:api_id => api_id).first  # get the response for the given (unique) api_id

            if self.class.has_blank_value?(response_hash) #If the value is blank, remove the response Ex: a checkbox was unchecked, which means the response was undone/removed
              existing.destroy if existing
            else

              updateable_attributes = response_hash.reject { |k, _v| k == 'api_id' }

              # this is where we check for malformed attributes for the answer_id:
              cleaned_up_answer_attributes = fix_malformed_answer_ids updateable_attributes # FIXME rename method 'fix_malformed_answer_ids' after revising it to handle updated parameter structure
              cleaned_up_answer_attributes['survey_section_id'] = Question.find(cleaned_up_answer_attributes['question_id']).survey_section.id

              if existing # (existing Response; it wasn't an unchecked/unselected checkbox/radio)
                if existing.question_id.to_s != cleaned_up_answer_attributes['question_id']
                  fail "Illegal attempt to change question for response #{api_id}."
                end

                existing.update_attributes(cleaned_up_answer_attributes)
              else

                responses.build(cleaned_up_answer_attributes).tap do |r|
                  r.api_id = api_id
                  #r.survey_section_id = Question.find(cleaned_up_answer_attributes['question_id']).survey_section.id
                  r.save!
                end
              end

            end

          end
        end
      end

      # ----------------------------------------------------------------------------------------------------------------

      protected
      # FIXME removes empty answer arrays and sets answer_id to the value of the answer array
      def fix_malformed_answer_ids(attribute_params)
        ans_key = :answer_id

        fixed_params = attribute_params
        if attribute_params.fetch(ans_key, false)
          answer_id_val = attribute_params[ans_key]
          if answer_id_val.is_a? Array
            # remove any blank strings from the Array, arbitrarily use the last value
            fixed_params[ans_key] = answer_id_val.compact.reject(&:empty?).last
          end
        end
        fixed_params
      end

      def dependencies(question_ids = nil)
        question_ids = survey.sections.map(&:questions).flatten.map(&:id) if responses.blank? and question_ids.blank?
        deps = Dependency.joins(:dependency_conditions).where({ dependency_conditions: { question_id: question_ids || responses.map(&:question_id) } })
        # this is a work around for a bug in active_record in rails 2.3 which incorrectly eager-loads associations when a
        # condition clause includes an association limiter
        deps.each { |d| d.dependency_conditions.reload }
        deps
      end
    end
  end
end
