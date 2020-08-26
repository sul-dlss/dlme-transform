# frozen_string_literal: true

module Macros
  # Macros for extracting TEI values from Nokogiri documents
  module Tei
    NS = {
      tei: 'http://www.tei-c.org/ns/1.0',
      py: 'http://codespeak.net/lxml/objectify/pytype'
    }.freeze
    private_constant :NS

    include Traject::Macros::NokogiriMacros

    # Returns the data provider value from the repository and institution values in the TEI XML.
    # @return [Proc] a proc that traject can call for each record
    def generate_data_provider(xpath)
      lambda do |record, accumulator|
        repository = record.xpath("#{xpath}/tei:repository", TrajectPlus::Macros::Tei::NS).map(&:text)
        institution = record.xpath("#{xpath}/tei:institution", TrajectPlus::Macros::Tei::NS).map(&:text)
        accumulator << [repository, institution].join(', ')
      end
    end

    # Looks up the main language from the TEI document and normalizes it using
    # the ++lib/translation_maps/marc_languages.yaml++ table
    # @return [Proc] a proc that traject can call for each record
    def main_language
      tei_main_lang_xp = '/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:textLang/@mainLang'
      tei_lang_text_xp = '/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:textLang'
      first(
        extract_tei(tei_main_lang_xp, translation_map: ['marc_languages', default: '__passthrough__']),
        # the last one is separate to eventually pass fuzzy matching parameters
        extract_tei(tei_lang_text_xp, translation_map: ['marc_languages', default: '__passthrough__'])
      )
    end

    # Looks up the other languages from the TEI document and normalizes them
    # using the ++lib/translation_maps/marc_languages.yaml++ table
    # @return [Proc] a proc that traject can call for each record
    def other_languages
      tei_other_langs_xp = '/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/' \
                           'tei:textLang/@otherLangs'
      new_pipeline = TrajectPlus::Extraction::TransformPipeline.new(translation_map: 'marc_languages')
      lambda do |record, accumulator|
        node = record.xpath(tei_other_langs_xp, TrajectPlus::Macros::Tei::NS).first
        accumulator.concat(new_pipeline.transform(node.value.split(' '))) if node
      end
    end

    # Sets a literal URL for public domain
    # @return [Proc] a proc that traject can call for each record
    def public_domain
      lambda do |_, accumulator|
        accumulator << 'http://creativecommons.org/publicdomain/mark/1.0/'
      end
    end

    # Sets a url for the given query
    # @param [String] query an xpath expression
    # @return [Proc] a proc that traject can call for each record
    def penn_image_uri(query)
      lambda do |record, accumulator, context|
        # Identifier without the prefix
        id = context.output_hash['id'].first.sub(/^[^_]*_/, '')
        path = extract_tei(query).call(record, [], context).first if url.present?
        accumulator << penn_uri(id, path)
      end
    end

    private

    def penn_uri(id, path)
      "http://openn.library.upenn.edu/Data/0001/#{id}/data/#{path}"
    end
  end
end
