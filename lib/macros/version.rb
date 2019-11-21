# frozen_string_literal: true

module Macros
  # Macro for setting the transform_version to the proper github hash
  module Version
    # Sets a literal to the current Github hash from the environment
    #   if it's available (for the docker image)
    # @return [Proc] a proc that traject can call for each record
    def version
      lambda do |_, accumulator|
        accumulator << ENV.fetch('VERSION', `git rev-parse --short HEAD`.strip)
      end
    end
  end
end
