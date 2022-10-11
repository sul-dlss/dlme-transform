# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module QNL
    def generate_qnl_iiif_id(record, context)
      ids = CSV.parse(record['id'].delete('[]').gsub("', '", "','"), liberal_parsing: true, quote_char: "'").flatten.reject(&:blank?)
      return default_identifier(context) unless ids.any?

      ids.first.strip.gsub(/_\w\w/, '_dlme')
    end
  end
end
