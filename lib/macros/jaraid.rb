# frozen_string_literal: true

require 'nokogiri'

module Macros
  # Macros for processing Jaraid data.
  # This module provides methods to extract specific information from TEI XML
  # documents related to Jaraid publications and their authority files.
  # rubocop:disable Metrics/ModuleLength
  module Jaraid
    NS = { 'tei' => 'http://www.tei-c.org/ns/1.0' }.freeze
    private_constant :NS

    def self.extended(context)
      context.instance_eval do
        jaraid_path = File.expand_path('../jaraid/jaraid_master-biblStruct.TEIP5.xml', __dir__)
        authority_path = File.expand_path('../jaraid/jaraid_authority-file.TEIP5.xml', __dir__) # <-- Update filename if needed

        @jaraid_doc ||= Nokogiri::XML(File.read(jaraid_path))
        @jaraid_authority_doc ||= Nokogiri::XML(File.read(authority_path))
      end
    end

    include Traject::Macros::NokogiriMacros

    # Generic macro to extract values from jaraid XML given an XPath
    # Starts with IDs in accumulator, replaces them with values from XML
    #
    # @param xpath [String] The XPath expression to apply.
    # @return [Proc] A Traject macro lambda.
    # rubocop:disable Lint/UnusedMethodArgument -- transform argument is not used
    def extract_jaraid(xpath, transform: nil)
      lambda do |_record, accumulator, _context|
        ids = accumulator.dup
        accumulator.clear

        ids.each do |jaraid_id|
          bibl = @jaraid_doc.at_xpath("//tei:biblStruct[tei:monogr/tei:idno[@type='jaraid']='#{jaraid_id}']", NS)
          next unless bibl

          # rubocop:disable Performance/MapMethodChain -- Rubocop suggests map { |x| x.text.strip }
          values = bibl.xpath(xpath, NS).map(&:text).map(&:strip).reject(&:empty?)
          # rubocop:enable Performance/MapMethodChain
          accumulator.concat(values.compact)
        end
      end
    end
    # rubocop:enable Lint/UnusedMethodArgument

    # Extract coordinates from authority file based on jaraid:place ID in pubPlace/@ref
    def jaraid_coordinates_from_pubplace
      lambda do |_record, accumulator, _context|
        refs = accumulator.flatten.dup
        accumulator.clear

        refs.each do |ref|
          geon_id = extract_geon_id(ref)
          next unless geon_id

          geo_coordinate = find_geo_coordinate_in_authority_file(geon_id)
          accumulator << geo_coordinate if geo_coordinate && !geo_coordinate.empty?
        end
      end
    end

    def jaraid_place_refs_from_id
      lambda do |_record, accumulator, _context|
        ids = accumulator.flatten.dup
        accumulator.clear

        ids.each do |jaraid_id|
          bibl = @jaraid_doc.at_xpath("//tei:biblStruct[tei:monogr/tei:idno[@type='jaraid']='#{jaraid_id}']", NS)
          next unless bibl

          process_place_ref_nodes(bibl, accumulator) # Extracted helper
        end
        accumulator.uniq!
      end
    end

    # Extract editors' names (und-Latn)
    def jaraid_editors
      extract_jaraid(".//tei:editor/tei:persName[@xml:lang='und-Latn']")
    end

    # Extract editors' names (Arabic)
    def jaraid_editors_ar
      extract_jaraid(".//tei:editor/tei:persName[@xml:lang='ar']")
    end

    # Extract publication places (und-Latn)
    def jaraid_pub_places
      extract_jaraid(".//tei:imprint/tei:pubPlace/tei:placeName[@xml:lang='und-Latn']")
    end

    # Extract publication places (Arabic)
    def jaraid_pub_places_ar
      extract_jaraid(".//tei:imprint/tei:pubPlace/tei:placeName[@xml:lang='ar']")
    end

    def jaraid_pub_dates
      lambda do |_record, accumulator, _context|
        ids = accumulator.dup
        accumulator.clear

        ids.each do |jaraid_id|
          bibl = @jaraid_doc.at_xpath("//tei:biblStruct[tei:monogr/tei:idno[@type='jaraid']='#{jaraid_id}']", NS)
          next unless bibl

          extract_and_add_pub_dates(bibl, accumulator) # Extracted helper
        end
      end
    end

    # Extract publishers' names (und-Latn)
    def jaraid_publishers
      extract_jaraid(".//tei:imprint/tei:publisher/tei:orgName[@xml:lang='und-Latn']")
    end

    # Extract publishers' names (Arabic)
    def jaraid_publishers_ar
      extract_jaraid(".//tei:imprint/tei:publisher/tei:orgName[@xml:lang='ar']")
    end

    # Extract note content for given note type, e.g. 'comment', 'sources', 'holdings'
    def jaraid_notes(note_type)
      extract_jaraid(".//tei:note[@type='#{note_type}']")
    end

    # Extract titles with level='j'
    def jaraid_title
      extract_jaraid(".//tei:title[@level='j']")
    end

    private

    # Helper for jaraid_coordinates_from_pubplace: Extracts geon ID from a ref string.
    # @param ref [String] The reference string (e.g., "geon:12345").
    # @return [String, nil] The geon ID if found, nil otherwise.
    def extract_geon_id(ref)
      match = ref.match(/geon:(\d+)/)
      match[1] if match
    end

    # Helper for jaraid_coordinates_from_pubplace: Finds geo coordinate in authority file.
    # @param geon_id [String] The geon ID.
    # @return [String, nil] The geo coordinate string if found, nil otherwise.
    def find_geo_coordinate_in_authority_file(geon_id)
      place_node = @jaraid_authority_doc.at_xpath("//tei:place[tei:idno[@type='geon']='#{geon_id}']", NS)
      place_node&.at_xpath('.//tei:location/tei:geo', NS)&.text&.strip
    end

    # Helper for jaraid_place_refs_from_id: Processes placeName ref nodes.
    # @param bibl [Nokogiri::XML::Element] The biblStruct element.
    # @param accumulator [Array] The Traject accumulator.
    def process_place_ref_nodes(bibl, accumulator)
      ref_nodes = bibl.xpath('.//tei:imprint/tei:pubPlace/tei:placeName[@ref]', NS)
      ref_nodes.each do |node|
        refs = node['ref'].to_s.split(/\s+/) # in case it's space-separated like: "jaraid:place:105 geon:105343"
        refs.each do |ref|
          accumulator << ref.strip unless ref.strip.empty?
        end
      end
    end

    # Helper for jaraid_pub_dates: Extracts and adds publication dates.
    # @param bibl [Nokogiri::XML::Element] The biblStruct element.
    # @param accumulator [Array] The Traject accumulator.
    def extract_and_add_pub_dates(bibl, accumulator)
      dates = bibl.xpath('.//tei:imprint/tei:date', NS).map do |date_node|
        date_node['when'] || date_node.text.strip
      end.reject(&:empty?)
      accumulator.concat(dates)
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
