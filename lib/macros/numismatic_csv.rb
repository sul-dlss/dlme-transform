# frozen_string_literal: true

module Macros
  # Macros for extracting values from CSV rows
  module NumismaticCsv
    # Returns the data provider value from the department columns and ++agg_provider++
    # field of ++metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    def provider_department
      lambda do |row, accumulator, context|
        accumulator << "#{row['Department']} Department, #{context.output_hash['agg_provider'].first}"
      end
    end
  end
end
