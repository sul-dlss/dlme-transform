# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module OAI
    NS = {
      oai: 'http://www.openarchives.org/OAI/2.0/',
      dc: 'http://purl.org/dc/elements/1.1/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    }.freeze
    private_constant :NS

    PREFIX = '/oai:record/oai:metadata/oai_dc:dc/'
    private_constant :PREFIX

    include Traject::Macros::NokogiriMacros

    # Extracts values for the given xpath which is prefixed with oai and oai_dc wrappers
    # @example
    #   extract_oai('dc:language') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_oai(xpath)
      extract_xpath("#{PREFIX}#{xpath}", ns: NS)
    end

    # Extracts values for the OAI identifier
    # @example
    #   extract_oai_identifier => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def extract_oai_identifier
      extract_xpath('/oai:record/oai:header/oai:identifier', ns: NS)
    end
  end
end
