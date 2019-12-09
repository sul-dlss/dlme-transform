# frozen_string_literal: true

module Macros
  # Macros for extracting Stanford Specific MODS values from Nokogiri documents
  module Princeton
    # Removes all but the last value from accumulator, if more values were present.
    #
    # @example
    #     to_field "main_author", extract_marc("100"), last_only
    def last_only
      lambda do |_rec, acc|
        acc.slice!(0, acc.length - 1)
      end
    end
  end
end
