# frozen_string_literal: true

require 'exception_collector'
require 'parse_date'

# Macros for Traject transformations.
module Macros
  # Macros for parsing dates from Strings
  module DateParsing

    # ---------- General macros follow, alphabetical except for additional helper methods

    # given an accumulator containing a string with both hijri and gregorian date info,
    #   change the string to only contain gregorian date info
    def extract_gregorian
      lambda do |_record, accumulator|
        accumulator.map! do |val|
          hijri_val = hijri_from_mixed(val)
          if hijri_val
            val.split(hijri_val).join(' ')
          else
            val
          end
        end
      end
    end

    # given an accumulator containing a string that may (or may not) have both hijri and gregorian date info,
    #   get a hijri range, either directly from the provided hijri dates or converted from the gregorian if no
    #   hijri dates are provided.
    def extract_or_compute_hijri_range
      lambda do |_record, accumulator|
        hijri_range = []
        accumulator.each do |val|
          hijri_val = hijri_from_mixed(val)
          if hijri_val&.strip.present?
            hijri_range << ParseDate.parse_range(hijri_val)
          else
            gregorian_range = ParseDate.parse_range(val)
            hijri_range << (to_hijri(gregorian_range.first)..to_hijri(gregorian_range.last) + 1).to_a
          end
        end
        accumulator.replace(normalize_year_array(hijri_range))
      end
    end

    # HELPER METHOD for other macros - NOT A MACRO
    # Given an array of year values, return a flat, sorted array of unique values with `nil`s filtered out
    def normalize_year_array(years)
      return years if years.empty?

      years.flatten.compact.uniq.sort
    end

    # Takes an existing array of year integers and returns an array converted to hijri
    # with an additional year added to the end to account for the non-365 day calendar
    def hijri_range
      lambda do |_record, accumulator, _context|
        return if accumulator.empty?

        accumulator.replace((to_hijri(accumulator.first)..to_hijri(accumulator.last) + 1).to_a)
      end
    end

    HIJRI_MODIFIER = 1.030684
    HIJRI_OFFSET = 621.5643

    # HELPER METHOD for other macros - NOT A MACRO
    # @param [Integer] a single year to be converted
    # @return [Integer] a converted integer year
    # This method uses the first formula provided here: https://en.wikipedia.org/wiki/Hijri_year#Formula
    def to_hijri(year)
      return unless year.is_a? Integer

      (HIJRI_MODIFIER * (year - HIJRI_OFFSET)).floor
    end

    REGEX_OPTS = Regexp::IGNORECASE | Regexp::MULTILINE
    HIJRI_TAG = '(A.H.|AH|H)'
    HIJRI_TAG_B4_REGEX = Regexp.new("#{HIJRI_TAG}\s+(?<hijri>[^\(\)\/]*)", REGEX_OPTS)
    HIJRI_TAG_AFTER_REGEX = Regexp.new("(?<hijri>[^\(\)\/]*)\s+#{HIJRI_TAG}", REGEX_OPTS)

    # HELPER METHOD for other macros - NOT A MACRO
    # given a string with both hijri and gregorian date info (e.g. 'A.H. 986 (1578)'),
    #   change the string to only contain hijri date info
    def hijri_from_mixed(date_str)
      hijri_val = Regexp.last_match(:hijri) if date_str&.match(HIJRI_TAG_B4_REGEX)
      hijri_val = nil unless hijri_val&.match(/\d+/)
      hijri_val ||= Regexp.last_match(:hijri) if date_str&.match(HIJRI_TAG_AFTER_REGEX)
      hijri_val&.strip
    end

    # given an accumulator containing a string with date info,
    #   use parse_date gem to get an array of indicated years as integers
    #   See https://github.com/sul-dlss/parse_date for info on what it can parse
    def parse_range
      lambda do |_record, accumulator, context|
        range_years = []
        accumulator.each do |val|
          range_years << ParseDate.parse_range(val) if val&.strip.present?
        end
        accumulator.replace(normalize_year_array(range_years))
      rescue ParseDate::Error => e
        collect_exception!(context, e)
        accumulator.replace([])
      end
    end

    # ---------- Collection or Metadata format specific macros below, alphabetical except for additional helper methods

    AUC_DELIM = ';'
    AUC_REGEX = Regexp.new("\\d{4}#{AUC_DELIM}?") # captures the `YYYY; YYYY; YYYY; YYYY;` pattern

    # Extracts date range from American University of Cairo data
    def auc_date_range
      lambda do |_record, accumulator, context|
        range_years = []
        accumulator.each do |val|
          range_years << val.scan(AUC_REGEX).map { |year| year.sub(AUC_DELIM, '').to_i }
          range_years << range_array(context, ParseDate.earliest_year(val), ParseDate.latest_year(val))
        end
        accumulator.replace(normalize_year_array(range_years))
      end
    end

    TEI_NS = { tei: 'http://www.tei-c.org/ns/1.0' }.freeze
    TEI_MS_DESC = '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc'
    TEI_MS_ORIGIN = 'tei:history/tei:origin'
    TEI_ORIG_DATE_PATH = "#{TEI_MS_DESC}/#{TEI_MS_ORIGIN}/tei:origDate"

    # extracts dates from TEI origDate element for Cambridge data
    # Best dates will be in notBefore/notAfter attributes, or from/to attributes
    # 'when' attribute is usually a single date;
    #  attributes may be empty or missing, in which case the element's value needs to be parsed
    # See specs for examples of all these flavors
    def cambridge_gregorian_range
      lambda do |record, accumulator, context|
        orig_date_node = record.xpath(TEI_ORIG_DATE_PATH, TEI_NS)&.first
        first = orig_date_node&.attribute('notBefore') ||
                orig_date_node&.attribute('from') ||
                orig_date_node&.attribute('when')
        last = orig_date_node&.attribute('notAfter') ||
               orig_date_node&.attribute('to') ||
               orig_date_node&.attribute('when')
        first = first&.value&.strip
        last = last&.value&.strip
        if first.present? && last.present?
          first = ParseDate.earliest_year(first)
          last = ParseDate.latest_year(last)
        else
          date_str = orig_date_node&.text
          hijri_val = hijri_from_mixed(date_str)
          date_str = date_str.split(hijri_val).join(' ') if hijri_val
          first = ParseDate.earliest_year(date_str)
          last = ParseDate.latest_year(date_str)
        end
        accumulator.replace(range_array(context, first, last))
      end
    end

    FGDC_NS = { fgdc: 'http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd' }.freeze
    FGDC_TIMEINFO_XPATH = '/metadata/idinfo/timeperd/timeinfo'
    FGDC_SINGLE_DATE_XPATH = "#{FGDC_TIMEINFO_XPATH}/sngdate/caldate"
    FGDC_DATE_RANGE_XPATH = "#{FGDC_TIMEINFO_XPATH}/rngdates"
    # Note:  saw no "#{FGDC_TIMEINFO_XPATH}/mdattim" multiple dates path data

    # Extracts dates from FGDC idinfo/timeperd to create a single date range value
    # a year will be nil if it is NOT between -9999 and (current year + 1), per parse_date gem
    # see https://www.fgdc.gov/metadata/csdgm/09.html, https://www.fgdc.gov/metadata/documents/MetadataQuickGuide.pdf
    def fgdc_date_range
      lambda do |record, accumulator, context|
        date_range_nodeset = record.xpath(FGDC_DATE_RANGE_XPATH, FGDC_NS)
        if date_range_nodeset.present?
          first_year = ParseDate.earliest_year(date_range_nodeset.xpath('begdate', FGDC_NS)&.text&.strip)
          last_year = ParseDate.earliest_year(date_range_nodeset.xpath('enddate', FGDC_NS)&.text&.strip)
          accumulator.replace(range_array(context, first_year, last_year))
        else
          single_date_nodeset = record.xpath(FGDC_SINGLE_DATE_XPATH, FGDC_NS)
          accumulator.replace([ParseDate.earliest_year(single_date_nodeset.text&.strip)]) if single_date_nodeset.present?
        end
      end
    end

    GREGORIAN_IN_BRACKET_REGEX = /\[(?<gregorian>.*\d{3,4}.*)\]/.freeze
    HIJRI_IE_GREGORIAN_REGEX = /\d.*i\.?e\.?(?<gregorian>.*\d{3,4}.*)/.freeze
    UU_TRAILING_HYPHEN_REGEX = /\d+uu\-$/.freeze

    # Extracts date range from Harvard IHP data
    # if the first value has [] chars, take the value inside the brackets and use parse_date
    # if the first value has i.e., take the value after i.e. and use parse_date
    # if the first value has no [ and no i.e., take the value and use parse_date
    # if no result, take the second value and use parse_date
    def harvard_ihp_date_range
      lambda do |_record, accumulator|
        return nil if accumulator.empty?

        first_val = accumulator.first
        if !first_val.match(GREGORIAN_IN_BRACKET_REGEX).nil?
          result = ParseDate.parse_range(Regexp.last_match(:gregorian).sub('or', '-'))
        elsif !first_val.match(HIJRI_IE_GREGORIAN_REGEX).nil?
          result = ParseDate.parse_range(Regexp.last_match(:gregorian).sub('or', '-'))
        elsif !first_val.match?(/\[/)
          result = if first_val.match?(UU_TRAILING_HYPHEN_REGEX)
                     ParseDate.parse_range(first_val.chop)
                   else
                     ParseDate.parse_range(first_val)
                   end
        end

        unless result
          second_val = accumulator[1]
          result = ParseDate.parse_range(second_val)
        end

        if result
          accumulator.replace(result)
        else
          accumulator.clear
        end
      end
    end

    # Extracts dates from slice of MARC 008 field
    #  to_field "date_range", extract_marc("008[06-14]"), marc_date_range
    #  or, if you have marcxml, get the correct bytes from 008 into the accumulator then call this
    # see https://www.loc.gov/marc/bibliographic/bd008a.html
    # does NOT work for BC dates (or negative dates) - because MARC 008 isn't set up for that
    def marc_date_range
      lambda do |_record, accumulator, context|
        val = accumulator.first
        date_type = val[0]
        unless date_type.match?(/[cdeikmqrs]/)
          accumulator.replace([])
          return
        end

        # these work for date_type.match?([cdikmq])
        first_year = ParseDate.earliest_year(val[1..4])
        last_year = ParseDate.latest_year(val[5..8])
        if date_type.match?(/[se]/)
          last_year = ParseDate.latest_year(val[1..4])
        elsif date_type == 'r'
          first_year = ParseDate.earliest_year(val[5..8])
        end
        accumulator.replace(range_array(context, first_year, last_year))
      end
    end

    # Extracts earliest & latest dates from Met record and merges into singe date range value
    def met_date_range
      lambda do |record, accumulator, context|
        first_year = record['objectBeginDate']
        last_year = record['objectEndDate']
        accumulator.replace(range_array(context, first_year, last_year))
      end
    end

    # Extracts date range from MODS dateCreated, dateValid or dateIssued elements
    #   looks in each element flavor for specific attribs to get best representation of date range
    def mods_date_range
      lambda do |record, accumulator, context|
        range = range_from_mods_date_element('mods:dateCreated', record, context) ||
                range_from_mods_date_element('mods:dateValid', record, context) ||
                range_from_mods_date_element('mods:dateIssued', record, context)
        accumulator.replace(range) if range
      end
    end

    # Extracts date range from Harvard SCW MODS dateCreated element
    #   looks in each element flavor for specific attribs to get best representation of date range
    def harvard_mods_date_range
      lambda do |record, accumulator, context|
        range = range_from_harvard_mods_date_range('mods:dateCreated', record, context)
        accumulator.replace(range) if range
      end
    end

    # Extracts date range from Harvard SCW MODS dateCreated element
    #   looks in each element flavor for specific attribs to get best representation of date range
    def range_from_harvard_mods_date_range(xpath_el_name, record, context)
      return unless record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)

      start_node = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='start']", MODS_NS)&.first
      if start_node
        first = start_node&.content&.split&.first&.strip
        end_node = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='end']", MODS_NS)&.first
        last = end_node&.content&.split&.first&.strip
        return range_array(context, first, last) if first && last
      end
      key_date_node = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}[@keyDate='yes']", MODS_NS)&.first
      if key_date_node
        year_str = key_date_node&.content&.strip
        return ParseDate.parse_range(year_str) if year_str
      end
      plain_node_value = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)&.first&.content
      return ParseDate.parse_range(plain_node_value) if plain_node_value
    end

    # Extracts date range from Stanford subject/temporal element
    # because the resources are historical maps with more recent GIS data.
    # The date in the MODS date fields refers to the latter but the former is more useful for search.
    def stanford_maps_date_range
      lambda do |record, accumulator, context|
        range = range_from_mods_date_element('/*/mods:subject/mods:temporal', record, context)
        accumulator.replace(range) if range
      end
    end

    MODS_NS = { mods: 'http://www.loc.gov/mods/v3' }.freeze
    ORIGIN_INFO_PATH = '//mods:mods/mods:originInfo'

    # HELPER METHOD for other macros - NOT A MACRO
    # given the namespace prefixed name for a MODS date element in mods:originInfo,
    # extract date range if available
    #   - look for attribute 'point' on element for "start" and "end" and use those values for range
    #   - if no "start" and "end", look for 'keyDate' attribute and parse element value for range
    #   - if no keyDate, take the first value and parse it for range
    # @return [Array, nil] Array of Integers for date range, or nil if unable to find a date range
    def range_from_mods_date_element(xpath_el_name, record, context)
      return unless record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)

      start_node = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='start']", MODS_NS)&.first
      if start_node
        first = start_node&.content&.strip
        end_node = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='end']", MODS_NS)&.first
        last = end_node&.content&.strip
        return range_array(context, first, last) if first && last
      end
      key_date_node = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}[@keyDate='yes']", MODS_NS)&.first
      if key_date_node
        year_str = key_date_node&.content&.strip
        return ParseDate.parse_range(year_str) if year_str
      end
      plain_node_value = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)&.first&.content
      return ParseDate.parse_range(plain_node_value) if plain_node_value
    end

    # Extracts earliest & latest dates from Penn museum record and merges into singe date range value
    def penn_museum_date_range
      lambda do |record, accumulator, context|
        first_year = record['date_made_early'].to_i if record['date_made_early']&.match(/\d+/)
        last_year = record['date_made_late'].to_i if record['date_made_late']&.match(/\d+/)
        accumulator.replace(range_array(context, first_year, last_year))
      end
    end

    # sakip records with multiple dates tend to have earliest year as the 2nd occurence
    # of dc:date and latest year as the 3rd occurrence of dc:date.  This algorithm covers
    # the vast majority of reliable date information provided for Kitapvehat and ResimKlksyn colls.
    def sakip_mult_dates_range
      lambda do |_record, accumulator, context|
        return if accumulator.empty?

        if accumulator[1]&.strip&.match?(/^\d{4}$/) && accumulator[2]&.strip&.match?(/^\d{4}$/)
          accumulator.replace(range_array(context, accumulator[1], accumulator[2]))
        else
          accumulator.clear
        end
      end
    end

    # Parse a range of years from two years.
    #
    # This method wraps the associated method in `ParseDate` and provides the
    # ability to trap date parsing errors, allowing the transform to return an
    # empty result for the field instead of raising an exception.
    def range_array(context, first_year, last_year)
      ParseDate.range_array(first_year, last_year)
    rescue ParseDate::Error => e
      collect_exception!(context, e)
      []
    end

    # Collection a transformation except along with its context for later
    # display, at the end of a transformation run
    def collect_exception!(context, exception)
      Dlme::ExceptionCollector.instance <<
        "ERROR parsing dates in #{context.input_name}: #{exception.message}. Offending record: #{context.source_record}"
    end
  end
end
