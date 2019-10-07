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
        range_years.flatten!.uniq! if range_years.any?
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

    # Extracts earliest & latest dates from Penn museum record and merges into singe date range value
    def penn_museum_date_range
      lambda do |record, accumulator, _context|
        first_year = record['date_made_early'].to_i if record['date_made_early']&.match(/\d+/)
        last_year = record['date_made_late'].to_i if record['date_made_late']&.match(/\d+/)
        accumulator.replace(Macros::DateParsing.year_array(first_year, last_year))
      end
    end

    # Extracts earliest & latest dates from American Numismatic Society record and merges into singe date range value
    def american_numismatic_date_range
      lambda do |record, accumulator|
        if record['Year']
          dates = record['Year'].split('|') #if record['Year']
          first_year = dates[0].to_i if dates[0]&.match(/\d+/)
          last_year = dates[1].to_i if dates[1]&.match(/\d+/)
        end
        accumulator.replace(Macros::DateParsing.year_array(first_year, last_year))
      end
    end

    # @param [String] first_year, expecting parseable string for .to_i
    # @param [String] last_year year, expecting parseable string for .to_i
    # @return [Array] array of Integer year values from first to last, inclusive
    def self.year_array(first_year, last_year)
      first_year = first_year.to_i if first_year.is_a? String
      last_year = last_year.to_i if last_year.is_a? String

      return [] unless last_year || first_year
      return [first_year] if last_year.nil? && first_year
      return [last_year] if first_year.nil? && last_year
      raise(StandardError, "unable to create year array from #{first_year}, #{last_year}") unless
        year_range_valid?(first_year, last_year)

      Range.new(first_year, last_year).to_a
    end

    def self.year_range_valid?(first_year, last_year)
      return false if first_year > Date.today.year + 2 || last_year > Date.today.year + 2
      return false if first_year > last_year

      true
    end
  end
end
