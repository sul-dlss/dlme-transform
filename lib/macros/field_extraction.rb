# frozen_string_literal: true

require 'traject_plus'

module Macros
  # DLME helpers for traject mappings
  module FieldExtraction
    extend TrajectPlus::Macros::JSON
    NS = {
      cdwalite: 'http://www.getty.edu/research/conducting_research/standards/cdwa/cdwalite',
      dc: 'http://purl.org/dc/elements/1.1/',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    # Extracts value from the first column if available, or the second column if the first is not available.
    def column_or_other_column(column, second_column) # rubocop:disable Metrics/AbcSize
      lambda do |row, accumulator, _context|
        return if row[column].to_s.empty? && row[second_column].to_s.empty?

        result = row[column].to_s.empty? ? Array(row[second_column].to_s) : Array(row[column].to_s)
        accumulator.concat(result)
      end
    end

    # Extracts fields_to_extract from json_list
    def extract_json_list(json_list, field_to_extract)
      lambda do |record, accumulator|
        values = []
        list = record[json_list]
        return unless list

        list.each do |val|
          values << val[field_to_extract]
        end
        accumulator.replace(values)
      end
    end

    def extract_json_from_context(path)
      lambda do |record, accumulator|
        result = record[path]
        accumulator.replace([result]) if result
      end
    end

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
