# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'activesupport', '~> 5.2'
gem 'config'
gem 'dry-validation'
gem 'faraday'
gem 'faraday_middleware'
gem 'parse_date'
gem 'rake'
gem 'thor', '~> 0.20' # for CLI
gem 'traject_plus', '~> 1.3'

group :development, :test do
  gem 'byebug'
  gem 'pry-byebug'
end

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'simplecov', '~> 0.21'
end
