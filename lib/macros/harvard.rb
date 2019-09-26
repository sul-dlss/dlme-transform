# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module Harvard
    NS = {
      dc: 'http://purl.org/dc/elements/1.1/'
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
      extract_xpath('/*/dc:identifier[1]', ns: NS)
    end

    def extract_harvard_thumb
      lambda do |record, accumulator, _context|
        id = record.xpath('/*/dc:identifier')
                   .find { |node| node.text.include?('iiif') || node.text.include?('usethumb=y') }
                   .text
        accumulator << id
      end
    end
  end
end
