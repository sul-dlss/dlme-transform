# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module QNL
    NS = {
      oai: 'http://www.openarchives.org/OAI/2.0/',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    PREFIX = '/oai:record/oai:metadata/mods:mods/'
    # PREFIX = '/oai:record/oai:metadata/oai_dc:dc/'
    private_constant :PREFIX

    def self.extended(mod)
      mod.extend Traject::Macros::NokogiriMacros
    end

    # Extracts values for the given xpath which is prefixed with oai and mods wrappers
    # @example
    #   extract_mods('mods:language') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_mods(xpath)
      extract_xpath("#{PREFIX}#{xpath}", ns: NS)
    end

    # Extracts values for the MODS identifier
    # @example
    #   extract_mods_identifier => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def extract_mods_identifier
      extract_xpath('/oai:record/oai:header/oai:identifier', ns: NS)
    end
  end
end
