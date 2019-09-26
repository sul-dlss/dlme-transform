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

    EXTRA_PREFIX = 'srw:record/srw:extraRecordData/'
    private_constant :EXTRA_PREFIX

    include Traject::Macros::NokogiriMacros

    # Extracts values for the given xpath which is prefixed with srw and oai wrappers
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    # @example
    #   extract_srw('dc:language') => lambda { ... }
    def extract_srw(xpath)
      extract_xpath("#{PREFIX}#{xpath}", ns: NS)
    end

    # Extracts thumnail from the srw:extraRecordData
    # @return [Proc] a proc that traject can call for each record
    # @example
    #   extract_thumbnail() => lambda { ... }
    def extract_thumbnail
      extract_extra('thumbnail')
    end

    # Extracts a link from the srw:extraRecordData
    # @return [Proc] a proc that traject can call for each record
    # @example
    #   extract_link() => lambda { ... }
    def extract_link
      extract_extra('link')
    end

    private

    # Extracts values from the srw:extraRecordData
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    # @example
    #   extract_extra('thumbnail') => lambda { ... }
    def extract_extra(field)
      extract_xpath("#{EXTRA_PREFIX}#{field}", ns: NS)
    end
  end
end
