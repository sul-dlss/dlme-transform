# frozen_string_literal: true

module Macros
  # Macro for setting the transform_version to the proper github hash
  module Timestamp
    # Sets a literal to the current timestamp
    # @return [Proc] a proc that traject can call for each record
    def timestamp
      lambda do |_, accumulator|
        accumulator << Time.now
      end
    end
  end
end
