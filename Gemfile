source 'https://rubygems.org'

ruby '2.2.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use PostgreSQL
gem 'pg'
gem 'redis'
gem 'redis-namespace'
gem 'redis-activesupport'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

gem "font-awesome-rails"

gem 'devise'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '~> 3.0.0'
gem 'omniauth-google-oauth2', '~> 0.4.0'

gem 'kaminari'
gem 'ancestry'
gem 'acts-as-taggable-on'
gem 'responders'
gem 'foundation-rails'
gem 'foundation_rails_helper'
gem 'acts_as_votable'
gem 'recaptcha', require: "recaptcha/rails"
gem 'cancancan'
gem 'social-share-button', git: 'https://github.com/huacnlee/social-share-button.git', ref: 'e46a6a3e82b86023bc'
gem 'initialjs-rails', '0.2.0.1'
gem 'unicorn', '~> 5.0.1'
gem 'paranoia'
gem 'rinku', require: 'rails_rinku'
gem 'savon'
gem 'faraday'
gem 'dalli'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra'
gem 'daemons'
gem 'devise-async'
gem 'whenever', require: false
gem 'pg_search'
gem 'foreman'

gem 'ahoy_matey', '~> 1.2.1'
gem 'groupdate'   # group temporary data
gem 'tolk' # Web interface for translations
gem 'roadie-rails'
gem 'normalize-rails'
gem 'html_truncator'

gem "settingslogic"

gem 'browser'
gem 'turnout'
gem 'redcarpet'
gem "faker"

gem 'rails-i18n'
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-9-stable'
gem 'friendly_id', '~> 5.1.0'
gem 'momentjs-rails'

# React gems
gem 'react-rails'
gem 'immutablejs-rails', '>= 2.0.17'
gem 'i18n-js', github: 'fnando/i18n-js'
gem 'markerclustererplus-rails'
gem 'modernizr-rails'

gem 'i18n_yaml_csv', github: 'josepjaume/i18n_yaml_csv'

gem 'draper'
gem 'roo' # implements read access for all common spreadsheet types

gem 'axlsx', '2.1.0.pre'

gem 'bourbon'

gem 'nokogiri'
gem 'rack-canonical-host'
gem 'rack-robots'
gem 'gaffe'
gem 'geocoder'
gem 'sitemap_generator'

gem 'postgres_ext'

gem "fog"
gem 'carrierwave', '~> 0.10.0'
gem 'mini_magick'
gem 'css_splitter'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rspec-rails', '~> 3.3'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'factory_girl_rails'
  gem 'fuubar'
  gem 'launchy'
  gem 'quiet_assets'
  gem 'letter_opener_web', '~> 1.3.0'
  gem 'i18n-tasks'
  gem "bullet"
  gem "vcr"
end

group :test do
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'email_spec'
  gem "webmock"
  gem 'rspec-repeat'
  gem "coveralls"
  gem 'timecop'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
end

group :production do
  gem 'rack-attack'
  gem 'newrelic_rpm'
  gem 'puma'
  gem 'puma_worker_killer'
  gem 'heroku-deflater'
  gem 'rails_12factor'
  gem 'rollbar'
  gem 'rack-cache'
  gem 'rack-cors', :require => 'rack/cors'
end
