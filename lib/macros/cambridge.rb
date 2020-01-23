# frozen_string_literal: true

module Macros
  # Macros for extracting Stanford Specific MODS values from Nokogiri documents
  module Cambridge
    # Namespaces and prefixes for XML documents from Stanford
    NS = { tei: 'http://www.tei-c.org/ns/1.0' }.freeze

    # This is a ID for the Digital Object in its information context
    # @param [Nokogiri::Document] record
    # @return [String] the ID
    def extract_record_id(record)
      url = record.xpath('//tei:facsimile/tei:graphic/@url', NS).map(&:text).first
      url.gsub!('http://cudl.lib.cam.ac.uk/content/images/', '')
      url.gsub!(%r{-\d+-\d+_files\/8\/0_0.jpg}, '')
    end
  end
end
