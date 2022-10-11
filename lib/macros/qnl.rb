# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module QNL
    NS = {
      oai: 'http://www.openarchives.org/OAI/2.0/',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    AR_PREFIX = '/oai:record/oai:ar_metadata/mods:mods/'
    EN_PREFIX = '/oai:record/oai:en_metadata/mods:mods/'
    private_constant :AR_PREFIX
    private_constant :EN_PREFIX

    include Traject::Macros::NokogiriMacros

    # Extracts values for the given xpath which is prefixed with oai and mods wrappers
    # @example
    #   extract_qnl('mods:language') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_qnl_ar(xpath)
      extract_xpath("#{AR_PREFIX}#{xpath}", ns: NS)
    end

    # Extracts values for the given xpath which is prefixed with oai and mods wrappers
    # @example
    #   extract_qnl('mods:language') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_qnl_en(xpath)
      extract_xpath("#{EN_PREFIX}#{xpath}", ns: NS)
    end

    # Extracts values for the MODS identifier
    # @example
    #   extract_qnl_identifier => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def extract_qnl_identifier
      extract_xpath('/oai:record/oai:header/oai:identifier', ns: NS)
    end

    def generate_qnl_iiif_id(record, context)
      if record.xpath('/oai:record/oai:header/oai:identifier', NS).map(&:text).reject(&:blank?).any?
        record.xpath('/oai:record/oai:header/oai:identifier', NS).map(&:text).reject(&:blank?).first.strip.gsub(
          '_dlme', ''
        )
      else
        default_identifier(context)
      end
    end

    # Joins QNL name and role
    # @example
    #   name_with_role('en')
    # @return [Proc] a proc that traject can call for each record
    def name_with_role(lang)
      lambda do |record, accumulator|
        names = []
        roles = []
        name = record.xpath("/oai:record/oai:#{lang}_metadata/mods:mods/mods:name/mods:namePart", NS)
        name.each do |val|
          names << val&.content&.strip
        end
        role = record.xpath("/oai:record/oai:#{lang}_metadata/mods:mods/mods:name/mods:role/mods:roleTerm", NS)
        role.each do |val|
          roles << val&.content&.strip
        end
        name_and_role = names.zip(roles)
        name_with_role = []
        name_and_role.each do |val|
          name_with_role << (val[0] + ' (' + val[1] + ')')
        end
        accumulator.replace(name_with_role)
      end
    end
  end
end
