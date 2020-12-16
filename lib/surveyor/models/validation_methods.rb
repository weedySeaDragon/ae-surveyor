module Surveyor
  module Models
    module ValidationMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :answer, optional: false
        has_many :validation_conditions, :dependent => :destroy
        attr_accessible *PermittedParams.new.validation_attributes if defined? ActiveModel::MassAssignmentSecurity

        # Validations
        validates_presence_of :rule
        validates_format_of :rule, :with => /\A(?:and|or|\)|\(|[A-Z]|\s)+\Z/
      end



      def is_valid?(response_set)
        conditions_results = conditions_hash(response_set)
        # exclude and, or
        valid_conditions = validation_conditions.map { |vc| ["a","o"].include?(vc.rule_key) ? "#{vc.rule_key}(?!nd|r)" : vc.rule_key}
        each_valid_conditions_or = valid_conditions.join('|')
        rgx = Regexp.new(each_valid_conditions_or)

        # For each match in our rule with the rgx, look up the value in the conditions_results (will return a true or false). and then replace the match with the value ('true' or 'false')
        rule_condition_results = rule.gsub(rgx){|match| conditions_results[match.to_sym]}

        # Finally, evaluate the result of all of that (e.g. "true and false and true", etc.)
        eval(rule_condition_results)
      end

      # A hash of the conditions (keyed by rule_key) and their evaluation (boolean) in the context of response_set
      def conditions_hash(response_set)
        hash = {}
        response = response_set.responses.detect{|r| r.answer_id.to_i == self.answer_id.to_i}

        validation_conditions.each{|vc| hash.merge!(vc.to_hash(response))}
        hash
      end
    end
  end
end
