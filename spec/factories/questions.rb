# encoding: utf-8
require 'factory_bot'

FactoryBot.define do

  sequence(:question_display_order){|n| n }

  factory :question do
    survey_section  { nil }
    # survey_section_id       {}

    #question_group_id {}
    question_group { nil }

    text { "What is your favorite color?" }
    short_text { "favorite_color" }
    help_text { "just write it in the box" }
    pick { :none }
    reference_identifier   {|me| "q_#{me.object_id}"}
    # data_export_identifier  {}
    # common_namespace        {}
    # common_identifier       {}
    display_order { FactoryBot.generate(:question_display_order) }
    # display_type            {} # nil is default
    is_mandatory { false }
    # display_width           {}

    correct_answer { nil }
    correct_answer_id  { correct_answer.nil? ? nil : correct_answer.id }


    after(:build) do |question, _evaluator|
      question.correct_answer = build(:answer, question: question) if question.correct_answer.nil?
    end

  end

end
