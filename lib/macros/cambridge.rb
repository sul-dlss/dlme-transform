# frozen_string_literal: true

module Macros
  # Macros for extracting Cambridge Specific values from Nokogiri documents
  module Cambridge
    # Shortcut variables
    MS_CONTENTS = 'tei:msContents'
    MS_DESC = '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc'
    MS_ID = 'tei:msIdentifier'
    MS_ITEM = 'tei:msItem'
    MS_ORIGIN = 'tei:history/tei:origin'
    OBJ_DESC = 'tei:physDesc/tei:objectDesc'
    PROFILE_DESC = '//tei:teiHeader/tei:profileDesc/tei:textClass'
    PUB_STMT = '//tei:teiHeader/tei:fileDesc/tei:publicationStmt'
    SUPPORT_DESC = 'tei:supportDesc'

    TEI_MS_DESC = '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc'
    TEI_MS_ORIGIN = 'tei:history/tei:origin'
    TEI_ORIG_DATE_PATH = "#{TEI_MS_DESC}/#{TEI_MS_ORIGIN}/tei:origDate"

    # Namespaces and prefixes for XML documents
    NS = { tei: 'http://www.tei-c.org/ns/1.0' }.freeze

    # Extract and transform the extent, dimensions of Cambridge record.
    # @param [Nokogiri::Document] record
    # @return [String] the resource dimensions
    def cambridge_dimensions
      lambda do |record, accumulator|
        return unless extent(record)
        return unless height(record)
        return unless width(record)
        return unless unit(record)

        accumulator.replace(["#{extent(record)} Written height: #{height(record)} #{unit(record)},
           width: #{width(record)} #{unit(record)}"])
      end
    end

    def extent(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent", NS).map(&:text).blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent", NS).map(&:text).first.split("\n").first
    end

    def height(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:height", NS)
                      .map(&:text)
                      .blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:height", NS)
            .map(&:text)
            .first
    end

    def width(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:width", NS)
                      .map(&:text)
                      .blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:width", NS)
            .map(&:text)
            .first
    end

    def unit(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/@unit", NS).map(&:text).blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/@unit", NS).map(&:text).first
    end

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
