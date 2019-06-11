# frozen_string_literal: true

module Macros
  # Macros for extracting AIMS values from Nokogiri documents
  module AIMS
    NS = {
      content: 'http://purl.org/rss/1.0/modules/content/',
      wfw: 'http://wellformedweb.org/CommentAPI/',
      dc: 'http://purl.org/dc/elements/1.1/',
      atom: 'http://www.w3.org/2005/Atom',
      itunes: 'http://www.itunes.com/dtds/podcast-1.0.dtd',
      spotify: 'http://www.spotify.com/ns/rss'
    }.freeze
    private_constant :NS

    ITUNES = 'item/itunes:'
    private_constant :ITUNES

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

    # Extracts values for the given xpath which and prefixes them with itunes namespace
    # @example
    #   extract_itunes('author') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_itunes(xpath)
      extract_xpath("#{ITUNES}#{xpath}", ns: NS)
    end

    # Extracts thumbnail values
    # @example
    #   extract_thumbnail => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def extract_thumbnail
      extract_xpath("#{ITUNES}image/@href", to_text: false, ns: NS)
    end
  end
end
