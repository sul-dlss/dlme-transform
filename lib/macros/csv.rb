# frozen_string_literal: true

require 'active_support/inflector' # parameterize method is part of active support

module Macros
  # Macros for extracting values from CSV rows
  module Csv
    def normalize_prefixed_id(header_or_index)
      lambda do |row, accumulator, context|
        identifier = row[header_or_index].to_s.parameterize
        accumulator << identifier_with_prefix(context, identifier) if identifier.present?
      end
    end
  end
end
