source 'https://rubygems.org'

ruby_version = '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.8'


# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'

#--------------------------------
# Views and UX


gem 'sass-rails', '~> 5.0'

gem 'uglifier', '>= 1.3.0'

gem 'coffee-rails', '~> 4.1.0'


gem 'jquery-rails'

gem 'turbolinks'

gem 'dotenv'

gem 'bootstrap'   # bootstrap 4
gem 'rails-assets-tether', '>= 1.1.0'  # for tooltips, popovers positioning


gem 'simple_form'

gem 'font-awesome-sass'


# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby



gem 'devise'
gem 'pundit'

gem 'high_voltage'

gem 'routing-filter'   # for handling locale filters around routes



gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc


# Use ActiveModel has_secure_password
 gem 'bcrypt', '~> 3.1.7'


# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development



gem 'ffaker'  # Fake data for DB seeding (for demo)


#--------------------------------
# backups
#gem 'backup'
#gem 'whenever'


group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'shoulda-matchers'
  gem 'pundit-matchers'
  gem 'factory_girl_rails'
  #gem 'pry'
  #gem 'pry-byebug'

end



group :test do

  gem 'rspec-rails'
  gem 'cucumber-rails', require: false

end
