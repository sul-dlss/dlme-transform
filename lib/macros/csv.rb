# frozen_string_literal: true

require 'active_support/inflector' # parameterize method is part of active support

module Macros
  # Macros for extracting values from CSV rows
  module Csv
    # Grab the value from the given column and prefix it with the `inst_id` value
    # that is set in metadata_mapping.json
    # @param header_or_index [String,Integer] the value of the header or index that identifies the column
    def normalize_prefixed_id(header_or_index)
      lambda do |row, accumulator, context|
        identifier = row[header_or_index].to_s.parameterize
        accumulator << identifier_with_prefix(context, identifier) if identifier.present?
      end
    end
  end
end
