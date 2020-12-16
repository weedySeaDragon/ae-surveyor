# encoding: utf-8
# http://github.com/thoughtbot/factory_bot/tree/master
# require 'rubygems'
require 'factory_bot'


FactoryBot.define do


  factory :survey_translation do |t|
    t.locale { "es" }
    t.translation  do
      %(title: "Un idioma nunca es suficiente"

  survey_sections:
    one:
      title: "Uno"
  questions:
    hello:
      text: "¡Hola!"
    name:
      text: "¿Cómo se llama Usted?"
      answers:
        name:
          help_text: "Mi nombre es...")
      end
    association :survey
  end


  factory :dependency do
    # the dependent question
    question
    question_group { nil }
    # d.association :question # d.question_id       {}
    # d.association :question_group
    rule { 'A' }
  end


  factory :validation_condition do |v|
    v.association       :validation  # v.validation_id     {}
    v.rule_key          {"A"}
    v.question_id       {}
    v.operator          {"=="}
    v.answer_id         {}
    v.datetime_value    {}
    v.integer_value     {}
    v.float_value       {}
    v.unit              {}
    v.text_value        {}
    v.string_value      {}
    v.response_other    {}
    v.regexp            {}
  end

end
