# frozen_string_literal: true

require 'active_support/inflector' # parameterize method is part of active support
require 'byebug'
require 'csv'

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

        values = accumulator.first.gsub("', '", "','")
        accumulator.replace(CSV.parse(values.delete('[]'), liberal_parsing: true, quote_char: "'").first)
      end
    end
  end
end
