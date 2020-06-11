# frozen_string_literal: true

require 'byebug'

# Macros for Traject transformations.
module Macros
  # Macro to extract only the 856u field that includes the simurg url for CSIC.
  module Csic
    # Remove any 856u fields that do not include the simurg URL for CISC
    # @return [Proc] a proc that traject can call for each record
    def extract_preview
      lambda { |_record, accumulator, _context|
        accumulator&.filter! { |val| val.include?('simurg.bibliotecas.csic.es') }
      }
    end
  end
end
