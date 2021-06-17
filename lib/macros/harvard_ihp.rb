require 'macros/date_parsing'
# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module HarvardIHP
    NS = {
      HarvardDRS: 'http://hul.harvard.edu/ois/xml/ns/HarvardDRS',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    include Macros::DateParsing
    include Traject::Macros::NokogiriMacros

    # Builds iiif manifest from extracted iiif id or drs id. There are
    # two manifest url patterns depending on whether there is a drs id or
    # iiif id.
    # @example
    #   extract_ihp_manifest => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def extract_ihp_manifest
      lambda do |record, accumulator|
        url = record.xpath('//*/mods:extension/HarvardDRS:DRSMetadata/HarvardDRS:drsFileId', NS)&.first&.content&.strip
                           &.prepend('https://iiif.lib.harvard.edu/manifests/view/drs:')&.gsub('/view/drs', '/ids') ||
              record.xpath('//*/mods:extension/HarvardDRS:DRSMetadata/HarvardDRS:drsObjectId',
                           NS)&.first&.content&.strip
                           &.prepend('https://iiif.lib.harvard.edu/manifests/view/drs:')&.gsub('/view/', '/') ||
              record.xpath('//*/mods:location/mods:url[@access="preview"]', NS)&.first&.content
                           &.gsub('https://ids.lib.harvard.edu/ids/iiif/', '')&.split('/')&.first
                           &.prepend('https://iiif.lib.harvard.edu/manifests/ids:')
        accumulator << url if url
      end
    end

    # Extracts date range from MODS dateCreated, dateValid or dateIssued elements
    #   looks in each element flavor for specific attribs to get best representation of date range
    def ihp_date_range
      lambda do |record, accumulator, context|
        range = range_from_ihp_date_element('mods:dateCreated', record, context) ||
                range_from_ihp_date_element('mods:dateValid', record, context) ||
                range_from_ihp_date_element('mods:dateIssued', record, context)
        accumulator.replace(range) if range
      end
    end

    TRANSFORMS = %w[not_found
                    has_type
                    ihp_has_type].freeze

    # Determines the cho_has_type value for Harvard IHP records. If the record
    # has a contributor with 'scribe' or 'copyist' roles, it is a Manuscript.
    # Otherwise the first value from genre is extracted and mapped through a
    # translation map.
    # @example
    #   ihp_has_type => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def ihp_has_type
      lambda do |record, accumulator|
        roles = []
        role_node = record.xpath('//*/mods:name/mods:role/mods:roleTerm', NS)
        role_node.each do |val|
          roles << val&.content&.strip&.downcase
        end
        if roles.any? { |x| ['scribe.', 'copyist.'].include?(x) }
          accumulator.replace(['manuscript'])
        else
          has_type = accumulator.map!(&:downcase)
          accumulator.replace([has_type[0].gsub('text', 'book').gsub('mixed material', 'manuscript')]) if has_type[0].present?
        end
      end
    end

    # There is inconsistent usage of the @type="uniform" attribute/value in the Harvard IHP
    # records. This macro extracts the uniform title when available, else extracts the first title.
    # It avoids duplicating the title when the uniform title is the first title.
    # @example
    #   ihp_uniform_title => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def ihp_uniform_title
      lambda do |record, accumulator|
        uniform = record.xpath('//*/mods:titleInfo[@type="uniform"][1]/mods:title', NS)[0]&.content ||
                  record.xpath('//*/mods:titleInfo[1]', NS)[0]&.content&.squish
        accumulator.replace([uniform]) if uniform
      end
    end

    ORIGIN_INFO_PATH = '//*/mods:originInfo'

    # Extracts date range from Harvard SCW MODS dateCreated element
    # looks in each element flavor for specific attribs to get best representation of date range
    def range_from_ihp_date_element(xpath_el_name, record, _context)
      return unless record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)

      key_date_node = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}[@encoding='marc']", MODS_NS)&.first
      if key_date_node
        year_str = key_date_node&.content&.strip
        return ParseDate.parse_range(year_str) if year_str
      end
      plain_node_value = record.xpath("#{ORIGIN_INFO_PATH}/#{xpath_el_name}", MODS_NS)&.first&.content
      return ParseDate.parse_range(plain_node_value) if plain_node_value
    end
  end
end
