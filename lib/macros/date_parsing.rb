# frozen_string_literal: true

require 'timetwister'
require 'stanford-mods'

# Macros for Traject transformations.
module Macros
  # Macros for parsing dates from Strings
  module DateParsing
    # get array of year values in range, when string is:
    # yyyy-yyyy
    # yyyy - yyyy (can be one or more spaces by hyphen, but not other types of whitespace)
    # yyyy  (one element in result)
    #  will not work for negative numbers, or fewer than 4 digit years
    def range_array_from_positive_4digits_hyphen
      lambda do |_record, accumulator|
        range_years = []
        accumulator.each do |val|
          range_years << Timetwister.parse(val).first[:index_dates]
        end
        range_years.flatten!.uniq!
        accumulator.replace(range_years)
      end
    end

    # Parse strings like 'Sun, 12 Nov 2017 14:08:12 +0000' for a single year
    def single_year_from_string
      lambda do |_record, accumulator, _context|
        accumulator.map! do |val|
          Stanford::Mods::DateParsing.year_int_from_date_str(val)
        end
      end
    end
  end
end
