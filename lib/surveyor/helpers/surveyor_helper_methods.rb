module Surveyor
  module Helpers
    module SurveyorHelperMethods

      # Layout: stylsheets and javascripts
      def surveyor_includes
        stylesheet_link_tag('surveyor_all') + javascript_include_tag('surveyor_all')
      end


      # Helper for setting the (meta) page title. This can be used in a page
      # layout to set the title for a surveyor page.
      # You can override this method to customize it.  You can use information
      # in the response_set and also use I18n.t() localization.
      def surveyor_edit_header_page_title(response_set)
        "#{@section.title}"
      end



      # HTML to display the survey title ( used on app/views/surveyor/edit.html.haml )
      def survey_title
        @survey.translation(I18n.locale)[:title]
      end


      # Helper for displaying warning/notice/error flash messages
      def flash_messages(types)
        types.map {|type| content_tag(:div, "#{flash[type]}".html_safe, :class => type.to_s)}.join.html_safe
      end


      # Section: dependencies, menu, previous and next
      def dependency_explanation_helper(question, response_set)

        # Attempts to explain why this dependent question needs to be answered by referenced the dependent question and users response
        trigger_responses   = []
        dependent_questions = Question.find_all_by_id(question.dependency.dependency_conditions.map(&:question_id)).uniq
        response_set.responses.find_all_by_question_id(dependent_questions.map(&:id)).uniq.each do |resp|
          trigger_responses << resp.to_s
        end

        "&nbsp;&nbsp;#{I18n.t('surveyor.your_answer')} &quot;#{trigger_responses.join("&quot; and &quot;")}&quot; #{I18n.t('surveyor.to_question')} &quot;#{dependent_questions.map(&:text).join("&quot;,&quot;")}&quot;"
      end


      def menu_button_for(section)
        submit_tag(section.translation(I18n.locale)[:title], :name => "section[#{section.id}]")
      end


      def previous_section
        # use copy in memory instead of making extra db calls
        prev_index = [(@sections.index(@section) || 0) - 1, 0].max
        submit_tag(t('surveyor.previous_section').html_safe, :name => "section[#{@sections[prev_index].id}]") unless @sections[0] == @section
      end


      def next_section
        # use copy in memory instead of making extra db calls
        next_index = [(@sections.index(@section) || @sections.count) + 1, @sections.count].min
        @sections.last == @section ? submit_tag(t('surveyor.click_here_to_finish').html_safe, :name => "finish") : submit_tag(t('surveyor.next_section').html_safe, :name => "section[#{@sections[next_index].id}]")
      end


      # Questions
      def q_text(q, context=nil, locale=nil)

        question_text_class = 'question_text'

        q_text_span = "<span class='#{question_text_class}'>#{q.text_for(nil, context, locale)}</span>"

        q_next_num_span = if q.dependent? or q.display_type == "label" or q.display_type == "image" or q.part_of_group? then
                            ''
                          else
                            next_question_number(q)
                          end

        "#{q_next_num_span}#{q_text_span}"
      end


      def next_question_number(question)

        question_number_class = 'qnum'

        @n ||= 0
        "<span class='#{question_number_class}'>#{@n += 1}) </span>"
      end


      # Responses
      def rc_to_attr(type_sym)
        case type_sym.to_s
          when /^answer$/ then
            :answer_id
          else
            "#{type_sym.to_s}_value".to_sym
        end
      end


      def rc_to_as(type_sym)
        #See: issue https://github.com/justinfrench/formtastic/issues/728
        case type_sym.to_s
          when /(float|date|time|datetime)/ then
            :string
          when "integer" then
            :number
          else
            type_sym
        end
      end


      def generate_pick_none_input_html(value, default_value, css_class, response_class, disabled, input_mask, input_mask_placeholder, data_rules)
        html            = {}
        html[:class]    = [response_class, css_class].reject {|c| c.blank?}
        html[:value]    = value.blank? ? default_value : value
        html[:disabled] = disabled unless disabled.blank?
        html[:data]     = data_rules
        if input_mask
          html[:'data-input-mask']             = input_mask
          html[:'data-input-mask-placeholder'] = input_mask_placeholder unless input_mask_placeholder.blank?
        end
        html
      end


      # Responses
      def response_for(response_set, question, answer = nil, response_group = nil)
        return nil unless response_set && question && question.id
        result = response_set.responses.detect {|r| (r.question_id == question.id) && (answer.blank? ? true : r.answer_id == answer.id) && (r.response_group.blank? ? true : r.response_group.to_i == response_group.to_i)}
        result.blank? ? response_set.responses.build(:question_id => question.id, :response_group => response_group) : result
      end


      def response_idx(increment = true)
        @rc ||= 0
        (increment ? @rc += 1 : @rc).to_s
      end

    end
  end
end
