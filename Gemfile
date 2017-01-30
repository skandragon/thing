source 'https://rubygems.org'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

gem 'rails', '5.0.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'postgres_ext'

gem 'sass-rails'
gem 'coffee-rails'

#gem 'less-rails'
gem 'therubyracer', platform: :ruby, require: 'v8'

#gem 'less-js'

gem 'uglifier'

gem 'bootstrap', '~> 4.0.0.alpha6'

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

#gem 'twitter-bootstrap-rails' #, git: 'git://github.com/seyhunak/twitter-bootstrap-rails.git', branch: 'master'

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'debugger'

group :development, :test do
#  gem 'simplecov', platform: :ruby, require: false, group: :test
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'thin'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'coveralls', require: false
  gem 'test-unit'
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
  gem 'rb-readline'
end

group :production do
  gem 'unicorn', platform: :ruby
end

gem 'rack-mini-profiler'
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-rbenv'
gem 'haml-rails'
gem 'simple_form'
gem 'will_paginate'
gem 'devise'
gem 'dalli'
gem 'redis'
gem 'multa_arcana'
gem 'rubyzip'
gem 'prawn'
gem 'prawn-table'
gem 'ri_cal'
gem 'axlsx'
gem 'redcarpet'
gem 'htmlentities'
gem 'paper_trail'
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
gem 'roadie', :group => [ :development, :production ]
