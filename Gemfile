# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'activesupport', '~> 5.2'
gem 'dry-schema'
gem 'faraday'
gem 'thor', '~> 0.20'
# Pin traject_plus to 1.1.0 because 1.2.0 causes errors:
#
# [ERROR] Error loading configuration file config/mods_config.rb:11
# NoMethodError:undefined method `extended' for #<Traject::Indexer:0x0000564b796c1bd0>
# Did you mean? extend
# /usr/local/bundle/gems/traject-3.2.0/lib/traject/indexer.rb:231:in `rescue in block in load_config_file': ...
#
# Pin back to '~> 1.2' when https://github.com/sul-dlss/traject_plus/issues/33 is closed
gem 'traject_plus', '~> 1.1.0'

group :test do
  gem 'byebug'
  gem 'pry-byebug'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop', '~> 0.64.0'
  gem 'rubocop-rspec', '~> 1.21.0'
  gem 'simplecov'
end
