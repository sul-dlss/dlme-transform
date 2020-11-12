# frozen_string_literal: true

module Macros
  # Macros for extracting values from Nokogiri documents
  module AUB
    NS = {
      oai: 'http://www.openarchives.org/OAI/2.0/',
      dc: 'http://purl.org/dc/elements/1.1/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    }.freeze
    private_constant :NS

    include Traject::Macros::NokogiriMacros

    # Extracts values for the given xpath which is prefixed with oai and oai_dc wrappers
    # @example
    #   extract_oai('dc:language') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_poha(xpath)
      extract_xpath(xpath.to_s, ns: NS)
    end
  end
end
