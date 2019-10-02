# frozen_string_literal: true

module Macros
  # Macros for normalizing incoming metadata
  module NormalizeType
    # Maps extracted type values to a series of tranlation maps
    # @example
    #   normalize_language => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def normalize_type
      lambda do |_record, accumulator|
        accumulator.map!(&:downcase)
        translation_map = %w[not_found types marc-types
                             french-types turkish-types].map do |spec|
          Traject::TranslationMap.new(spec)
        end.reduce(:merge)
        translation_map.translate_array!(accumulator)
      end
    end
  end
end
