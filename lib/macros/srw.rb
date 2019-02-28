# frozen_string_literal: true

module Macros
  # Macros for extracting SRW values from Nokogiri documents
  module SRW
    NS = {
      dc: 'http://purl.org/dc/elements/1.1/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      srw: 'http://www.loc.gov/zing/srw/'
    }.freeze

    PREFIX = 'srw:record/srw:recordData/oai_dc:dc/'
    private_constant :PREFIX

    # Extracts values for the given xpath which is prefixed with srw and oai wrappers
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    # @example
    #   extract_oai('dc:language') => lambda { ... }
    def extract_srw(xpath, options = {})
      extract_xml("#{PREFIX}#{xpath}", NS, options)
    end
  end
end
