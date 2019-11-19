# frozen_string_literal: true

module Macros
  # Macros for Penn data extraction and transformation
  module Penn
    # Map extracted values to appropriate penn_cho_has_type values
    # @example
    #   penn_cho_has_type => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def penn_cho_has_type
      lambda do |_record, accumulator|
        if accumulator.first == 'Manuscript Fragment'
          accumulator.first.gsub('Manuscript Fragment', 'MS WORKED')
        elsif accumulator.first == 'Manuscript'
          accumulator.first.gsub('Manuscript', 'Manuscript ALSO WORKED')
        else
          accumulator.first.gsub(/./, 'Cultural Artifact')
        end
      end
    end
  end
end
