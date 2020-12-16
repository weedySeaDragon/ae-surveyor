# encoding: utf-8
require 'factory_bot'

FactoryBot.define do

  sequence(:unique_survey_access_code){|n| "simple survey #{UUIDTools::UUID.random_create.to_s}" }

  factory :survey do
    title { "Simple survey" }
    description { "A simple survey for testing" }
    access_code     { FactoryBot.generate :unique_survey_access_code }
    survey_version { 0 }
  end

end
