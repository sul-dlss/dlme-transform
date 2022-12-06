# frozen_string_literal: true

require 'active_support/inflector' # parameterize method is part of active support
require 'byebug'
require 'csv'
require 'yaml'

module Macros
  # Macros for extracting values from CSV rows
  module Csv
    # Grab the value from the given column and prefix it with the `inst_id` value
    # that is set in `config/metadata_mapping.json`
    # @param header_or_index [String,Integer] the value of the header or index that identifies the column
    def normalize_prefixed_id(header_or_index)
      lambda do |row, accumulator, context|
        identifier = row[header_or_index].to_s.parameterize
        accumulator << identifier_with_prefix(context, identifier) if identifier.present?
      end
    end

    # Determine if the value in the given column contains an array of values
    # return either the original value or the array value parsed into elements
    def parse_csv
      lambda do |_row, accumulator|
        return [] if accumulator.empty?
        return accumulator unless accumulator.first.match?(/[\[\]]/)

        values = CSV.parse(accumulator.first.gsub("', '", "','").delete('[]'), liberal_parsing: true, quote_char: "'")
        values.map!(&:compact)
        accumulator.replace(values.first)
      end
    end

    # Same as parse_csv but parses YAML instead of CSV.
    # We ran into an issue when parsing titles that were serialized like: ["'example,']
    # Assuming this works the goal is to move towards always parsing as YAML
    # with a parse_list function and to retire parse_csv
    def parse_yaml
      lambda do |_row, accumulator|
        return [] if accumulator.empty?
        return accumulator unless accumulator.first.match?(/[\[\]]/)

        values = YAML.safe_load(accumulator.first)
        accumulator.replace(values)
      end
    end
  end
end
