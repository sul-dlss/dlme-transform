# frozen_string_literal: true

module Macros
  # DLME helpers for traject mappings
  module FieldExtraction
    NS = {
      cdwalite: 'http://www.getty.edu/research/conducting_research/standards/cdwa/cdwalite',
      dc: 'http://purl.org/dc/elements/1.1/',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    # Extracts values and returns them, seperated by commas, with
    # a single prepend string. Avoids duplicating the prepend string
    # for each value in the accumulator.
    def xpath_commas_with_prepend(xpath, prepend_string)
      lambda do |record, accumulator|
        values = []
        node = record.xpath(xpath, NS)
        node.each do |val|
          values << val&.content&.strip
        end
        accumulator.replace(["#{prepend_string}#{values.join(', ')}"]) if values.present?
      end
    end

    # Extracts values and returns them, seperated by commas, with
    # a single prepend string. Avoids duplicating the prepend string
    # for each value in the accumulator. Does not work if more than one
    # field extracted to the same DLME field.
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/AbcSize
    def xpath_multi_lingual_commas_with_prepend(xpath, ar_prepend_string, latn_prepend_string)
      lambda do |record, accumulator|
        ar_values = []
        latn_values = []
        node = record.xpath(xpath, NS)
        node.each do |val|
          lang_code = val&.content&.strip&.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'ar' : 'latn'
          ar_values << val&.content&.strip if lang_code == 'ar'
          latn_values << val&.content&.strip if lang_code == 'latn'
        end
        accumulator.replace(["#{ar_prepend_string}#{ar_values.join(', ')}", "#{latn_prepend_string}#{latn_values.join(', ')}"]) if ar_values.present? && latn_values.present?
        accumulator.replace(["#{ar_prepend_string}#{ar_values.join(', ')}"]) if ar_values.present? && latn_values.empty?
        accumulator.replace(["#{latn_prepend_string}#{latn_values.join(', ')}"]) if ar_values.empty? && latn_values.present?
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/AbcSize
  end
end
