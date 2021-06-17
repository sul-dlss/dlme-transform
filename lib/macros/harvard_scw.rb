require 'macros/date_parsing'
require 'macros/string_helper'
# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module HarvardSCW
    NS = {
      cdwalite: 'http://www.getty.edu/research/conducting_research/standards/cdwa/cdwalite',
      HarvardDRS: 'http://hul.harvard.edu/ois/xml/ns/HarvardDRS',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    include Macros::DateParsing
    include Macros::StringHelper
    include Traject::Macros::NokogiriMacros

    # Extracts values for the given xpath which is prefixed with HarvardDRS wrappers
    # @example
    #   extract_harvard('HarvardDRS:drsObjectId') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_harvard(xpath)
      extract_xpath(xpath.to_s, ns: NS)
    end

    # Determines the cho_has_type value for Harvard SCW records. There is not
    # a single reliable source to map for this field so four fields are extracted,
    # appended to an array in a particular order, and the first match in the array
    # is passed to a translation map. It is a fragile process and not 100% accurate
    # but it seems mostly accurate and some data is better than none.
    # @example
    #   scw_has_type => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def scw_has_type
      lambda do |record, accumulator|
        type_values = []
        rejected_values = ['album', 'album leaf']
        genres = record.xpath('/*/mods:genre', NS)
        genres.each do |val|
          type_values << val&.content&.strip&.downcase&.gsub('single page painting/drawing', 'manuscript illumination') if val&.content&.present?
        end
        accumulator.replace(type_values - rejected_values)
      end
    end
  end
end
