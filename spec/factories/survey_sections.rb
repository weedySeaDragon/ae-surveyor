# encoding: utf-8
require 'factory_bot'

FactoryBot.define do

  sequence(:survey_section_display_order){|n| n }

  factory :survey_section do
    survey
    title                     {"Demographics"}
    description               {"Asking you about your personal data"}
    display_order             {FactoryBot.generate :survey_section_display_order}
    reference_identifier      {"demographics"}
    data_export_identifier    {"demographics"}
  end

end
