# frozen_string_literal: true

module Macros
  # Helpers for working with data from Bibliothèque nationale de France
  # @deprecated use SRW instead
  module BNF
    # Namespaces and prefixes for XML documents from Bibliothèque nationale de France
    NS = {
      dc: 'http://purl.org/dc/elements/1.1/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      srw: 'http://www.loc.gov/zing/srw/'
    }.freeze
  end
end
