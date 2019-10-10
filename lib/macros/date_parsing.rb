# frozen_string_literal: true

require 'timetwister'
require 'parse_date'

# Macros for Traject transformations.
module Macros
  # Macros for parsing dates from Strings
  module DateParsing
    # get array of year values in range, when string is:
    # yyyy; yyyy; yyyy; yyyy; yyyy
    # works with negative years, but will return an emtpy set of a string is detected
    def array_from_range
      lambda do |_record, accumulator|
        return if accumulator.empty?

        range_years = accumulator.first.delete(' ')

        unless range_years.match?(/^[0-9-;]+$/)
          accumulator.replace([])
          return
        end

        accumulator.replace(range_years.split(';').map!(&:to_i))
      end
    end

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
          ParseDate.earliest_year(val)
        end
      end
    end

    FGDC_NS = { fgdc: 'http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd' }.freeze
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
          first_year = ParseDate.earliest_year(date_range_nodeset.xpath('begdate', FGDC_NS)&.text&.strip)
          last_year = ParseDate.earliest_year(date_range_nodeset.xpath('enddate', FGDC_NS)&.text&.strip)
          accumulator.replace(Macros::DateParsing.year_array(first_year, last_year))
        else
          single_date_nodeset = record.xpath(FGDC_SINGLE_DATE_XPATH, FGDC_NS)
          accumulator.replace([ParseDate.earliest_year(single_date_nodeset.text&.strip)]) if single_date_nodeset.present?
        end
      end
    end

    # Extracts dates from slice of MARC 008 field
    #  to_field "date_range", extract_marc("008[06-14]"), marc_date_range
    #  or, if you have marcxml, get the correct bytes from 008 into the accumulator then call this
    # see https://www.loc.gov/marc/bibliographic/bd008a.html
    # does NOT work for BC dates (or negative dates) - because MARC 008 isn't set up for that
    def marc_date_range
      lambda do |_record, accumulator, _context|
        val = accumulator.first
        date_type = val[0]
        if date_type == 's'
          first_year = ParseDate.earliest_year(val[1..4])
          last_year = ParseDate.latest_year(val[1..4])
          accumulator.replace(Macros::DateParsing.year_array(first_year, last_year))
        elsif date_type.match?(/[cdikmq]/)
          first_year = ParseDate.earliest_year(val[1..4])
          last_year = ParseDate.latest_year(val[5..8])
          accumulator.replace(Macros::DateParsing.year_array(first_year, last_year))
        else
          accumulator.replace([])
        end
      end
    end

    # Takes an existing array of year integers and returns an array converted to hijri
    # with an additional year added to the end to account for the non-365 day calendar
    def hijri_range
      lambda do |_record, accumulator, _context|
        return if accumulator.empty?

        accumulator.replace((
          Macros::DateParsing.to_hijri(accumulator.first)..Macros::DateParsing.to_hijri(accumulator.last) + 1).to_a)
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

    HIJRI_MODIFIER = 1.030684
    HIJRI_OFFSET = 621.5643

    # @param [Integer] a single year to be converted
    # @return [Integer] a converted integer year
    # This method uses the first formula provided here: https://en.wikipedia.org/wiki/Hijri_year#Formula
    def self.to_hijri(year)
      return unless year.is_a? Integer

      (HIJRI_MODIFIER * (year - HIJRI_OFFSET)).floor
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
