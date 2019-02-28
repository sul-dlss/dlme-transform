# frozen_string_literal: true

module Macros
  # Macros for extracting SRW values from Nokogiri documents
  module SRW
    NS = {
      dc: 'http://purl.org/dc/elements/1.1/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      srw: 'http://www.loc.gov/zing/srw/'
    }.freeze

    # Extracts values for the given xpath
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_srw(xpath, options = {})
      extract_xml(xpath, NS, options)
    end
  end
end
