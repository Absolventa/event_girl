source 'https://rubygems.org'

ruby '2.2.2'
gem 'rails', '~> 4.2.0'

gem 'pg'

gem 'puma'

gem 'sass-rails', '~> 4.0.2' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
gem 'bootstrap-sass', '~> 2.3.2.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'

gem 'simple_form'
gem 'select2-rails'
gem 'haml'

gem 'responders', '~> 2.0'
gem 'will_paginate'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

gem 'jbuilder', '~> 1.2' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'actionpack-xml_parser', '~> 1.0.0'

gem 'whenever', require: false
gem 'slack-notifier'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.0'

# Use unicorn as the app server
# gem 'unicorn'

group :production do
  gem 'rails_12factor', '0.0.3'
end

group :development, :test do
  gem 'web-console', '~> 2.0'
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-collection_matchers'
  gem 'rspec-activemodel-mocks'
end

group :test do
  gem 'shoulda'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem "codeclimate-test-reporter", require: false
  gem 'timecop'
  gem 'zonebie'

  gem 'capybara'
  gem 'launchy'
  gem 'webmock'
end
