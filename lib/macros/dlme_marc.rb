# frozen_string_literal: true

require 'traject_plus'

# Macros for Traject transformations.
module Macros
  # Macros that change some of Traject's MARC behaviors for the sake of DLME.
  module DlmeMarc
    # Looks up the role from the MARC record
    # @param [String] marc_field the MARC field identifier
    # @param [String] role  either "creator" or "contributor"
    # @return [Proc] a proc that traject can call for each record
    def extract_role(marc_field, role)
      lambda do |record, accumulator|
        record.each_by_tag(marc_field) do |field|
          if role == 'creator'
            accumulator.concat [field.value] if %w[creator author cre aut].include?(field['e'])
          elsif role == 'contributor'
            accumulator.concat [field.value] unless %w[creator author cre aut].include?(field['e'])
          end
        end
      end
    end

    # Looks up the type from the MARC document and normalizes it using the ++lib/translation_maps/types.yaml++ table
    # @return [Proc] a proc that traject can call for each record
    def marc_type_to_edm
      lambda { |record, accumulator, _context|
        leader06 = record.leader.byteslice(6)
        edm_types = TrajectPlus::Extraction.apply_extraction_options(leader06, translation_map: 'types')
        accumulator.concat(edm_types)
      }
    end
  end
end
