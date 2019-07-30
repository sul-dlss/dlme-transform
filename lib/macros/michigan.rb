# frozen_string_literal: true

module Macros
  # Macros for extracting Stanford Specific MODS values from Nokogiri documents
  module Michigan
    # Removes all but the first value from accumulator, if more values were present.
    #
    # @example
    #     to_field "main_author", extract_marc("100"), first_only
    def last_only
      lambda do |_rec, acc|
        # kind of esoteric, but slice used this way does mutating first, yep
        acc.slice!(0, acc.length - 1)
      end
    end
  end
end
