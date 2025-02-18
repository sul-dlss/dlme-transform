# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'activesupport'
gem 'config'
gem 'csv'
gem 'dry-validation'
gem 'faraday'
gem 'faraday_middleware'
gem 'ffi'
gem 'parse_date'
gem 'rake'
gem 'thor' # for CLI
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
