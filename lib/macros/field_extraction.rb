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
  end
end
