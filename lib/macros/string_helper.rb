# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/filters'

module Macros
  # String helper macros for traject mappings
  module StringHelper
    # Returns a string with new lines and whitespace removed.
    # @return [Proc] a proc that traject can call for each record
    # @example
    # "Part of the \n      Islamic Manuscripts |n    Collection" => "Part of the Islamic Manuscripts Collection"
    def squish
      lambda do |_rec, acc|
        acc.collect!(&:squish)
      end
    end

    # Returns a string with first letter of each word capitalized.
    # @return [Proc] a proc that traject can call for each record
    # @example
    # "the qur'an" => "The Qur'an"
    def titleize
      lambda do |_rec, acc|
        acc.collect!(&:titleize)
      end
    end

    # Shorten a string and follow it with an ellipsis.
    def truncate(text, length = 100, truncate_string = '...')
      l = length - truncate_string.chars.length
      (text.length > length ? text[0...l] + truncate_string : text).to_s
    end
  end
end
