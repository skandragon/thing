source 'https://rubygems.org'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'postgres_ext'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'less-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '~> 0.10.1', platform: :ruby, require: 'v8'

  gem 'uglifier', '>= 1.0.3'

  gem 'twitter-bootstrap-rails'
  gem 'bootstrap-editable-rails'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'debugger'

group :development, :test do
  gem 'simplecov', platform: :ruby, require: false, group: :test
  gem 'rspec-rails', '>= 2.12'
  gem 'thin'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'launchy'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'annotate'
  gem 'railroady'

  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end

group :production do
  gem 'unicorn', platform: :ruby
end

gem 'rack-mini-profiler'
gem 'strong_parameters'
gem 'capistrano'
gem 'haml-rails'
gem 'simple_form'
gem 'will_paginate'
gem 'devise'
gem 'dalli'
gem 'redis'
gem 'resque', require: 'resque/server'
gem 'multa_arcana'
gem 'rubyzip'
gem 'prawn', '>= 1.0.0.rc2'
gem 'ri_cal'
gem 'axlsx'
gem 'redcarpet'
gem 'htmlentities'
gem 'paper_trail', '~> 2'
gem 'active_model_serializers', '~> 0.7.0'
gem 'hashie'
gem 'diff-lcs'
