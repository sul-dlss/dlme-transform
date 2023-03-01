# frozen_string_literal: true

require 'pathname'

module Macros
  # Macro for setting the collection of the current data file
  module PathToFile
    # Returns the file path for the transformed record
    # @return [Proc] a proc that traject can call for each record
    def path_to_file
      lambda do |_, accumulator, context|
        accumulator << File.join(Pathname(context.input_name)).gsub('/opt/airflow/working', '')
      end
    end
  end
end
