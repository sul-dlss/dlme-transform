# frozen_string_literal: true

require 'pathname'

module Macros
  # Macro for setting the collection of the current data file
  module Collection
    # Drops the first default_data_path and the file from the pathname as collection
    # @return [Proc] a proc that traject can call for each record
    def collection
      lambda do |_, accumulator, context|
        accumulator << File.join(Pathname(context.input_name).each_filename.to_a[1...-1])
      end
    end
  end
end
