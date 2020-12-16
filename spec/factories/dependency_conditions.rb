# encoding: utf-8

require 'factory_bot'

FactoryBot.define do

  factory :dependency_condition, class: 'DependencyCondition' do

    dependency { nil }
    rule_key { 'A' }

    # the conditional question
    # Uncommenting this causes a problem with this factory:
    #    NameError: uninitialized constant DependencyCondition::question
    association :dependent_question, factory: :question

    association :question, factory: :question

    association :answer

    operator { '=='}

    datetime_value    { nil }
    integer_value     { nil }
    float_value       { nil }
    unit              { nil }
    text_value        { nil }
    string_value      { nil }
    response_other    { nil }
  end

end
