# frozen_string_literal: true

# %w(favorites feelings lifestyle numbers favorites-ish everything).each do |name|

fixtures_dir = File.join(__dir__, '..', 'fixtures')
prefix = 'seed_'
suffix = '_survey.rb'

%w[favorites].each do |name|
  shared_context name do
    before do
      survey_file = File.join(fixtures_dir, "#{prefix}#{name}#{suffix}")
      File.open(survey_file, 'r') do |file|
        instance_exec{file.read}
      end
    end
    # before { Surveyor::Parser.parse_file( File.join(Rails.root, '..',  'fixtures', "#{name}.rb"), trace: false) }
  end
end
