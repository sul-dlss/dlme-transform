# frozen_string_literal: true

module Macros
  # Macros for extracting AIMS values from Nokogiri documents
  module AIMS
    NS = {
      content: 'http://purl.org/rss/1.0/modules/content/',
      wfw: 'http://wellformedweb.org/CommentAPI/',
      dc: 'http://purl.org/dc/elements/1.1/',
      atom: 'http://www.w3.org/2005/Atom',
      PREFIX: 'http://www.PREFIX.com/dtds/podcast-1.0.dtd',
      spotify: 'http://www.spotify.com/ns/rss',
      media: 'http://search.yahoo.com/mrss/'
    }.freeze
    private_constant :NS

    PREFIX = 'item/'
    private_constant :PREFIX

    def self.extended(mod)
      mod.extend Traject::Macros::NokogiriMacros
    end

    # Extracts values for the given xpath
    # @example
    #   extract_aims('title') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_aims(xpath)
      extract_xpath("#{PREFIX}#{xpath}", ns: NS)
    end

    # Extracts thumbnail values
    # @example
    #   extract_thumbnail => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def extract_thumbnail
      extract_xpath("#{PREFIX}media:content/@url", to_text: false, ns: NS)
    end
  end
end
