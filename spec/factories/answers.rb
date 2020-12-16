# encoding: utf-8
require 'factory_bot'

FactoryBot.define do

  sequence(:answer_display_order) { |n| n }

  factory :answer do
    association :question # question_id               {}
    text { "My favorite color is clear" }
    short_text { "clear" }
    help_text { "Clear is the absense of color" }
    # weight
    response_class { "string" }
    # reference_identifier      {}
    # data_export_identifier    {}
    # common_namespace          {}
    # common_identifier         {}
    display_order { FactoryBot.generate :answer_display_order }
    # is_exclusive              {}
    display_type { "default" }
    # display_length            {}
    # custom_class              {}
    # custom_renderer           {}
  end

end
