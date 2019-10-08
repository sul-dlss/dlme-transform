# frozen_string_literal: true

require 'timetwister'
require 'parse_date'

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
    # nil if the year is NOT between -999 and (current year + 2), per parse_date gem
    def single_year_from_string
      lambda do |_record, accumulator, _context|
        accumulator.map! do |val|
          ParseDate.year_int_from_date_str(val)
        end
      end
    end

    FGDC_NS = { fgdc: 'http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd' }
    FGDC_TIMEINFO_XPATH = '/metadata/idinfo/timeperd/timeinfo'
    FGDC_SINGLE_DATE_XPATH = "#{FGDC_TIMEINFO_XPATH}/sngdate/caldate"
    FGDC_DATE_RANGE_XPATH = "#{FGDC_TIMEINFO_XPATH}/rngdates"
    # Note:  saw no "#{FGDC_TIMEINFO_XPATH}/mdattim" multiple dates path data

    # Extracts dates from FGDC idinfo/timeperd to create a singe date range value
    # a year will be nil if it is NOT between -999 and (current year + 2), per parse_date gem
    # see https://www.fgdc.gov/metadata/csdgm/09.html, https://www.fgdc.gov/metadata/documents/MetadataQuickGuide.pdf
    def fgdc_date_range
      lambda do |record, accumulator, _context|
        date_range_nodeset = record.xpath(FGDC_DATE_RANGE_XPATH, FGDC_NS)
        if date_range_nodeset.present?
          first_year = ParseDate.year_int_from_date_str(date_range_nodeset.xpath('begdate', FGDC_NS)&.text&.strip)
          last_year = ParseDate.year_int_from_date_str(date_range_nodeset.xpath('enddate', FGDC_NS)&.text&.strip)
          accumulator.replace(Macros::DateParsing.year_array(first_year, last_year))
        else
          single_date_nodeset = record.xpath(FGDC_SINGLE_DATE_XPATH, FGDC_NS)
          if single_date_nodeset.present?
            accumulator.replace([ParseDate.year_int_from_date_str(single_date_nodeset.text&.strip)])
          end
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
