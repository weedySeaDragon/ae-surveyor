require 'rspec'

# This file is customized to run specs withing the testbed environemnt
# ENV["RAILS_ENV"] ||= 'test'

# begin
  # require File.expand_path("dummy/config/environment", __dir__)
# rescue LoadError => e
  # fail "Could not load the dummy app. Have you generated it?\n#{e.class}: #{e}"
# end

# require 'rspec/rails'
# require 'rspec/autorun'

# require 'capybara/rails'
# require 'capybara/rspec'
# require 'capybara/poltergeist'
# require 'factories'
require 'json_spec'
# require 'database_cleaner'
# require 'rspec/retry'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
 Dir["./spec/support/**/*.rb"].sort.each {|f| require f}


# Capybara.javascript_driver = :poltergeist


RSpec.configure do |config|

  config.include JsonSpec::Helpers
  config.include SurveyorAPIHelpers
  config.include SurveyorUIHelpers
  config.include WaitForAjax

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # config.expect_with :rspec do |c|
  #   c.syntax = :expect
  # end

  # Settings from rails_helper that can be used here:
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = File.join(__dir__, 'fixtures')

  # config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  # config.infer_base_class_for_anonymous_controllers = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # rspec-retry
  # https://github.com/rspec/rspec-core/issues/456
  # config.verbose_retry       = true # show retry status in spec process
  # retry_count                = ENV['RSPEC_RETRY_COUNT']
  # config.default_retry_count = retry_count.try(:to_i) || 1
  # puts "RSpec retry count is #{config.default_retry_count}"


  #
  # ## Database Cleaner
  # config.before :suite do
  #   DatabaseCleaner.clean_with :truncation
  #   DatabaseCleaner.strategy = :transaction
  # end

  config.before do

    # set the default strategy to use :transaction
    #   except if an example has a :clean_with_truncation tag or :js tag
    #  @see http://stackoverflow.com/a/29427190/661471
    #
    # using transaction as the default is not the norm

    # config.before(:suite) do
    #   if self.class.metadata[:clean_with_truncation] || self.class.metadata[:js]
    #     DatabaseCleaner.strategy = :truncation
    #     DatabaseCleaner.clean_with(:truncation)
    #   else
    #     DatabaseCleaner.strategy = :transaction
    #     DatabaseCleaner.clean_with(:transaction)
    #   end
    # end

    # config.before(:each) do
    #
    #   # Clean before each example unless clean_with_truncation || js is set
    #   unless self.class.metadata[:clean_with_truncation] || self.class.metadata[:js]
    #     DatabaseCleaner.strategy = :truncation
    #   end
    #
    # end

    #
    # if example.metadata[:clean_with_truncation] || example.metadata[:js]
    #   DatabaseCleaner.strategy = :truncation
    # else
    #   DatabaseCleaner.strategy = :transaction
    # end

    # DatabaseCleaner.start
  end
  #
  # config.after do
  #   DatabaseCleaner.clean
  # end

end

JsonSpec.configure do
  exclude_keys "id", "created_at", "updated_at", "uuid", "modified_at", "completed_at"
end
