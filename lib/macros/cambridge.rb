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

    # Namespaces and prefixes for XML documents
    NS = { tei: 'http://www.tei-c.org/ns/1.0' }.freeze

    def cambridge_dimensions
      lambda do |record, accumulator|
        return unless all_dimension_info?(record)

        accumulator.replace(["#{extent(record)} #{height_width_str(record, 0)}".strip])
        accumulator << height_width_str(record, 1).strip if height(record).length > 1
      end
    end

    # @param [Nokogiri::Document] record from which to get dimension lists
    # @param [Integer] idx which set of dimensions to stringify
    def height_width_str(record, idx)
      "#{meausured_object(record)[idx].capitalize}: "\
        "(height: #{height(record)[idx]} #{unit(record)[idx]}, width: #{width(record)[idx]} #{unit(record)[idx]})"
    end

    def all_dimension_info?(record)
      extent(record) && height(record) && meausured_object(record) && unit(record) && width(record)
    end

    def extent(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/text()[last()]", NS).map(&:text).blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/text()[last()]", NS).map(&:text)
            .first
            .split("\n")
            .first
    end

    def height(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:height", NS)
                      .map(&:text)
                      .blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:height", NS)
            .map(&:text)
    end

    def meausured_object(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/@type", NS).map(&:text).blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/@type", NS).map(&:text)
    end

    def unit(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/@unit", NS).map(&:text).blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/@unit", NS).map(&:text)
    end

    def width(record)
      return if record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:width", NS)
                      .map(&:text)
                      .blank?

      record.xpath("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent/tei:dimensions/tei:width", NS)
            .map(&:text)
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
