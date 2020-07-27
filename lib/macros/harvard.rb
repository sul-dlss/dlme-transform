# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module Harvard
    NS = {
      dc: 'http://purl.org/dc/elements/1.1/',
      HarvardDRS: 'http://hul.harvard.edu/ois/xml/ns/HarvardDRS',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    include Traject::Macros::NokogiriMacros

    # Extracts values for the given xpath which is prefixed with dc wrappers
    # @example
    #   extract_harvard('dc:language') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_harvard(xpath)
      extract_xpath(xpath.to_s, ns: NS)
    end

    # Extracts values for the Harvard identifier
    # @example
    #   extract_harvard_identifier => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def extract_harvard_identifier
      extract_xpath('//*/dc:identifier[1]', ns: NS)
    end

    def extract_harvard_thumb
      lambda do |record, accumulator, _context|
        id = record.xpath('//*/dc:identifier', dc: NS[:dc])
                   .find { |node| node.text.include?('iiif') || node.text.include?('usethumb=y') }
        accumulator << { 'wr_id' => [id.text] } unless id.nil?
      end
    end

    GREGORIAN_IN_BRACKET_REGEX = /\[(?<gregorian>.*\d{3,4}.*)\]/.freeze
    HIJRI_IE_GREGORIAN_REGEX = /\d.*i\.?e\.?(?<gregorian>.*\d{3,4}.*)/.freeze
    IHP_ORIGIN_INFO_PATH = '/*/*/mods:mods/mods:originInfo'
    MODS_NS = { mods: 'http://www.loc.gov/mods/v3' }.freeze
    SCW_ORIGIN_INFO_PATH = '/*/mods:originInfo'
    UU_TRAILING_HYPHEN_REGEX = /\d+uu\-$/.freeze

    # Extracts date range from Harvard IHP data
    # if the first value has [] chars, take the value inside the brackets and use parse_date
    # if the first value has i.e., take the value after i.e. and use parse_date
    # if the first value has no [ and no i.e., take the value and use parse_date
    # if no result, take the second value and use parse_date
    # def harvard_ihp_date_range
    #   lambda do |_record, accumulator|
    #     return nil if accumulator.empty?
    #
    #     first_val = accumulator.first
    #     if !first_val.match(GREGORIAN_IN_BRACKET_REGEX).nil?
    #       result = ParseDate.parse_range(Regexp.last_match(:gregorian).sub('or', '-'))
    #     elsif !first_val.match(HIJRI_IE_GREGORIAN_REGEX).nil?
    #       result = ParseDate.parse_range(Regexp.last_match(:gregorian).sub('or', '-'))
    #     elsif !first_val.match?(/\[/)
    #       result = if first_val.match?(UU_TRAILING_HYPHEN_REGEX)
    #                  ParseDate.parse_range(first_val.chop)
    #                else
    #                  ParseDate.parse_range(first_val)
    #                end
    #     end
    #
    #     unless result
    #       second_val = accumulator[1]
    #       result = ParseDate.parse_range(second_val)
    #     end
    #
    #     if result
    #       accumulator.replace(result)
    #     else
    #       accumulator.clear
    #     end
    #   end
    # end

    # Extracts date range from Harvard SCW MODS dateCreated element
    #   looks in each element flavor for specific attribs to get best representation of date range
    def harvard_ihp_has_type
      lambda do |record, accumulator, _context|
        manuscript = record.xpath('/*/*/mods:mods/mods:typeOfResource[@manuscript="yes"]', mods: NS[:mods])&.first
        other_value = record.xpath('/*/*/mods:mods/mods:genre', mods: NS[:mods])&.first&.content
        if manuscript
          accumulator << "Manuscript"
        elsif other_value == "map"
          accumulator << "Map"
        else
          accumulator << "Book"
        end
      end
    end

    # Extracts date range from Harvard SCW MODS dateCreated element
    #   looks in each element flavor for specific attribs to get best representation of date range
    def harvard_ihp_date_range
      lambda do |record, accumulator, context|
        range = range_from_harvard_ihp_date_range('*[@encoding="marc"]', record, context)
        accumulator.replace(range) if range
      end
    end

    # Extracts date range from Harvard SCW MODS dateCreated element
    #   looks in each element flavor for specific attribs to get best representation of date range
    def range_from_harvard_ihp_date_range(xpath_el_name, record, context)
      return unless record.xpath("#{IHP_ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)
      start_node = record.xpath("#{IHP_ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='start']", MODS_NS)&.first
      if start_node
        first = start_node&.content&.split&.first&.strip&.gsub('u', '0')
        end_node = record.xpath("#{IHP_ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='end']", MODS_NS)&.first
        last = end_node&.content&.split&.first&.strip&.gsub('u', '0')
        return range_array(context, first, last) if first && last
      end
      key_date_node = record.xpath("#{IHP_ORIGIN_INFO_PATH}/#{xpath_el_name}[@keyDate='yes']", MODS_NS)&.first
      if key_date_node
        year_str = key_date_node&.content&.strip
        return ParseDate.parse_range(year_str) if year_str
      end
      plain_node_value = record.xpath("#{IHP_ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)&.first&.content
      return ParseDate.parse_range(plain_node_value) if plain_node_value
    end

    # Extracts date range from Harvard SCW MODS dateCreated element
    #   looks in each element flavor for specific attribs to get best representation of date range
    def harvard_scw_date_range
      lambda do |record, accumulator, context|
        range = range_from_harvard_scw_date_range('mods:dateCreated', record, context)
        accumulator.replace(range) if range
      end
    end

    # Extracts date range from Harvard SCW MODS dateCreated element
    #   looks in each element flavor for specific attribs to get best representation of date range
    def range_from_harvard_scw_date_range(xpath_el_name, record, context)
      return unless record.xpath("#{SCW_ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)

      start_node = record.xpath("#{SCW_ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='start']", MODS_NS)&.first
      if start_node
        first = start_node&.content&.split&.first&.strip
        end_node = record.xpath("#{SCW_ORIGIN_INFO_PATH}/#{xpath_el_name}[@point='end']", MODS_NS)&.first
        last = end_node&.content&.split&.first&.strip
        return range_array(context, first, last) if first && last
      end
      key_date_node = record.xpath("#{SCW_ORIGIN_INFO_PATH}/#{xpath_el_name}[@keyDate='yes']", MODS_NS)&.first
      if key_date_node
        year_str = key_date_node&.content&.strip
        return ParseDate.parse_range(year_str) if year_str
      end
      plain_node_value = record.xpath("#{SCW_ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)&.first&.content
      return ParseDate.parse_range(plain_node_value) if plain_node_value
    end
  end
end
