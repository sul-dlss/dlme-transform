# frozen_string_literal: true

module Macros
  # Macros for normalizing incoming metadata
  module Normalize
    # Extracts earliest & latest dates and merges into singe date range value
    # @example
    #   penn_museum_date_range => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def penn_museum_date_range
      lambda do |record, accumulator, _context|
        accumulator << [record['date_made_early'], record['date_made_late']].select(&:present?).join('/').presence
      end
    end
  end
end
