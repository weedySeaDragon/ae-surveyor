# encoding: utf-8
require 'factory_bot'
#
# unless defined? User
#   require 'active_model'
#
#   class User < ActiveRecord::Base
#     attr_accessor :id, :email
#   end
# end

FactoryBot.define do

  sequence(:email, 1) { |num| "email_#{num}@random.com" }

  factory :user do
    email
  end

end
