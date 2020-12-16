# encoding: utf-8
require 'factory_bot'

FactoryBot.define do

  factory :response_set do
    survey   # r.survey_id       {}

    access_code { Surveyor::Common.make_tiny_code }
    started_at { Time.now }
    completed_at {}
    responses { [] }

    user factory: :user

    transient do
      num_responses { 3 }
    end

    # the after(:create) yields two values; the user instance itself and the
    # evaluator, which stores all values from the factory, including transient
    # attributes; `create_list`'s second argument is the number of records
    # to create and we make sure the user is associated properly to the post
    after(:create) do |response_set, evaluator|
      create_list(:response, evaluator.num_responses, response_set: response_set)

      # You may need to reload the record here, depending on your application
      response_set.reload
      response_set
    end

    # after(:build) do |response_set, evaluator|
    #   response_set.responses = [ create(:response,
    #                                     api_id: response_set.api_id,
    #                                     response_set: response_set) ] if response_set.responses.nil?
    # end
  end

end
