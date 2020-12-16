require 'factory_bot'

FactoryBot.define do

  factory :validation do
    answer
    rule { "A" }
    message {}
  end

end
