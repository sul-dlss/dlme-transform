# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'activesupport', '~> 5.2'
gem 'config'
gem 'dry-validation'
gem 'faraday'
gem 'faraday_middleware'
gem 'ffi', '~> 1.16.3' # pin until 1.17.x is less platform dependent
gem 'httparty'
gem 'parse_date'
gem 'rake'
gem 'thor', '~> 0.20' # for CLI
gem 'traject_plus', '~> 1.3'
gem 'webmock'

group :development, :test do
  gem 'debug'
end

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'simplecov', '~> 0.21'
end
