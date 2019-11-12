# frozen_string_literal: true

# Macros for Traject transformations.
module Macros
  # Macros that change some of Traject's MARC behaviors for the sake of DLME.
  module DlmeMarc
    # Looks up the type from the MARC document and normalizes it using the ++lib/translation_maps/types.yaml++ table
    # @return [Proc] a proc that traject can call for each record
    def marc_type_to_edm
      lambda { |record, accumulator, _context|
        leader06 = record.leader.byteslice(6)
        edm_types = TrajectPlus::Extraction.apply_extraction_options(leader06, translation_map: 'marc-types')
        accumulator.concat(edm_types)
      }
    end
  end
end
