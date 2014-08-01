source 'https://rubygems.org'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

gem 'rails', '3.2.17'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'postgres_ext'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  if true
    gem 'therubyracer', platform: :ruby, require: 'v8'
    gem 'less-rails'
  else
    gem 'less'
    gem 'less-js'
  end

  gem 'uglifier'

  gem 'twitter-bootstrap-rails', git: 'git://github.com/seyhunak/twitter-bootstrap-rails.git', branch: 'bootstrap3'
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
  gem 'rspec-rails'
  gem 'thin'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'coveralls', require: false
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
gem 'capistrano-rails'
gem 'haml-rails'
gem 'simple_form'
gem 'will_paginate'
gem 'devise'
gem 'dalli'
gem 'redis'
gem 'resque', require: 'resque/server'
gem 'multa_arcana'
gem 'rubyzip'
gem 'prawn'
gem 'ri_cal'
gem 'axlsx', '~> 2'
gem 'redcarpet'
gem 'htmlentities'
gem 'paper_trail', '~> 2'
gem 'active_model_serializers'
gem 'hashie'
gem 'diff-lcs'
gem 'liquid'

#
# For HTML-format email that isn't so painful to format
# This gem crashes Ruby on my mac...  both macs...  so, remove it from
# test since we don't verify that the gem works, just that the email
# renders.
#
gem 'roadie', '~> 2.4', :group => [ :development, :production ]
