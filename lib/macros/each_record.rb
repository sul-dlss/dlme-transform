# frozen_string_literal: true

module Macros
  # Macros for post-processing data
  module EachRecord
    # Converts one or more fields from arrays or strings into hashes with language codes
    # @example
    #   convert_to_language_hash => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def convert_to_language_hash(*fields)
      lambda do |_record, context|
        context.output_hash.select { |key, _values| fields.include?(key) }.each do |key, values|
          result = Hash.new { [] }

          values.each do |value|
            case value
            when Hash
              result[value[:language]] += value[:values]
            else
              result['none'] += Array(value)
            end
          end

          context.output_hash[key] = result
        end
      end
    end
  end
end
