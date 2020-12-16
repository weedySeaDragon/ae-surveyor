# encoding: utf-8
require 'factory_bot'

FactoryBot.define do

  factory :response do
    response_set { nil }  # FIXME should this be nil?

    survey_section
    question
    answer

    survey_section_id { survey_section.id }
    question_id { question.id }
    answer_id { answer.id}

    datetime_value {}
    integer_value {}
    float_value {}
    unit {}
    text_value {}
    string_value {}
    response_other {}
    response_group {}
    api_id { nil }
  end

end
