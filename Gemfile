source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 7.1'
gem 'rails-i18n', '~> 7.0'
gem 'importmap-rails', '~> 1.2'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'puma', '~> 6.4'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'rack-mini-profiler', '~> 3.3'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'sqlite3', '~> 1.6'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'haml-rails', '~> 2.0'
gem 'bcrypt', '~> 3.1.19'
gem 'roo'
gem 'roo-xls'
gem 'simple_form'
gem 'midi-smtp-server', '~> 3.2', require: false
gem 'will_paginate', '~> 4.0'
gem 'will_paginate-bootstrap-style'
gem 'whenever', '~> 1.0', require: false
gem 'mysql2', '>=0.5'
gem 'base32'
gem 'net-ftp'
gem 'bootstrap', '~> 5.3.2'
gem 'jquery-rails'

gem "hotwire-rails", "~> 0.1.3"
