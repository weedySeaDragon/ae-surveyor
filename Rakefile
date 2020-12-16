$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'rake/task'
require 'fileutils'

require 'rspec/core/rake_task'

require 'tempfile'


###### RSPEC

#RSpec::Core::RakeTask.new(:spec)

#RSpec::Core::RakeTask.new(:rcov) do |spec|
#  spec.rcov = true
#end

task :default => :spec



namespace :factory_bot do
  desc "Lint factories: Verify that all FactoryBot factories are valid"
  task :lint do
    require 'active_record'

    if Rails.env.test?
      conn = ActiveRecord::Base.connection
      conn.transaction do
        FactoryBot.lint
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      fail if $?.exitstatus.nonzero?
    end
  end
end


###### TESTBED

desc 'Set up the rails app that the specs and features use'
task :testbed => 'testbed:rebuild'


namespace :testbed do

  TESTBED      = 'dummy'
  TESTBED_PATH = File.join(__dir__, 'spec', TESTBED)

  desc 'Generate a minimal surveyor-using rails app'
  task :generate do

    Tempfile.open('surveyor_Rakefile') do |f|
      f.write("application \"config.time_zone='Pacific Time (US & Canada)'\"\n")
      f.flush
      sh "bundle exec rails new #{TESTBED_PATH} --skip-bundle --database=postgresql  -m #{f.path}" # don't run bundle install until the Gemfile modifications
    end

    copy('Gemfile.rails_version', TESTBED_PATH)

    testbed_gemfile_path = File.join(TESTBED_PATH, 'Gemfile')

    cd(TESTBED_PATH) do
      gem_file_contents = File.read('Gemfile')
      gem_file_contents.sub!(/^(gem 'rails'.*)$/, %Q{# \\1\nplugin_root = File.expand_path('../../..', __FILE__)\neval(File.read 'Gemfile.rails_version')\ngem 'surveyor', :path => plugin_root})
      File.open(testbed_gemfile_path, 'w') { |f| f.write(gem_file_contents) }

      Bundler.with_clean_env do
        sh 'bundle install'   # run bundle install after Gemfile modifications
      end
    end

  end


  desc 'create and migrate the dummy test database'
  task :create_dbdb do

    chdir(TESTBED_PATH) do
      sh 'bundle exec rails db:environment:set RAILS_ENV=test'
      # installing surveyor will copy the db/migrate files, etc.
      sh 'bundle exec rails generate surveyor:install'
      sh 'bundle exec rails db:drop RAILS_ENV=test'
      sh 'bundle exec rails db:create RAILS_ENV=test'
      sh 'bundle exec rails db:migrate RAILS_ENV=test'
    end
  end


  desc 'Prepare the databases for the testbed'
  task :migrate do
    cd(TESTBED_PATH) do
      Bundler.with_clean_env do
        # sh 'bundle exec rails generate surveyor:install'
        sh 'bundle exec rails db:environment:set RAILS_ENV=test'
        sh 'bundle exec rails db:drop RAILS_ENV=test'
        sh 'bundle exec rails db:create RAILS_ENV=test'
        sh 'bundle exec rake db:migrate RAILS_ENV=test'
        sh 'bundle exec rake db:test:prepare RAILS_ENV=test'
      end
    end
  end


  desc 'Remove the testbed entirely'
  task :remove do
    rm_rf "#{TESTBED_PATH}"
  end


  task :rebuild => [:remove, :generate, :migrate]

  desc 'Load all the sample surveys into the testbed instance'
  task :surveys do
    cd(TESTBED_PATH) do
      Dir[File.join('surveys', '*.rb')].each do |fn|
        puts "Installing #{fn} into the testbed"
        system("rake surveyor FILE='#{fn}'")
      end
    end
  end


end
