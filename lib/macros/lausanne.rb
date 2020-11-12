# frozen_string_literal: true

module Macros
  # Macros for extracting values from Lausanne records
  module Lausanne
    # Extracts earliest & latest dates from Lausanne record and merges into singe date range value
    def lausanne_date_range
      lambda do |record, accumulator, context|
        accumulator.replace(range_array(context, first_year(record), last_year(record)))
      end
    end

    # Extracts earliest & latest dates from Lausanne record and merges into singe date string value
    def lausanne_date_string
      lambda do |record, accumulator|
        return unless first_year(record)
        return unless last_year(record)

        accumulator.replace(["#{first_year(record)} to #{last_year(record)}"])
      end
    end

    def first_year(record)
      return if record['from']&.match(/\d+/).blank?

      record['from']
    end

    def last_year(record)
      return if record['to']&.match(/\d+/).blank?

      record['to']
    end
  end
end
