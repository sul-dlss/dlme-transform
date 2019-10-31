# frozen_string_literal: true

require 'parse_date'

module Macros
  # Macros for extracting date ranges from AUC collections
  module AUC
    def normalize_date_range
      lambda do |_record, accumulator, _context|
        range_years = []
        accumulator.each do |val|
          range_years << ParseDate.range_array(ParseDate.earliest_year(val), ParseDate.latest_year(val))
        end

        range_years.flatten!.uniq! if range_years.any?
        accumulator.replace(range_years)
      end
    end
  end
end
