require 'factory_bot'

FactoryBot.define do

  factory :question_group do
    text { "Describe your family" }
    help_text {}
    reference_identifier { |me| "g_#{me.object_id}" }
    data_export_identifier {}
    common_namespace {}
    common_identifier {}
    display_type {}
    custom_class {}
    custom_renderer {}
    questions { [] }
  end

end
