# frozen_string_literal: true

module Macros
  # Macros for normalizing incoming metadata
  module NormalizeType
    # Maps extracted has type values to a series of tranlation maps
    # @example
    #   normalize_language => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def normalize_edm_type
      lambda do |_record, accumulator|
        accumulator.map!(&:downcase)
        translation_map = %w[edm_type_from_has_type].map do |spec|
          Traject::TranslationMap.new(spec)
        end.reduce(:merge)
        translation_map.translate_array!(accumulator)
      end
    end

    # Maps extracted has type values to a series of tranlation maps
    # @example
    #   normalize_language => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def normalize_has_type
      lambda do |_record, accumulator|
        accumulator.map!(&:downcase)
        translation_map = %w[has_type_from_contributor
                             has_type_from_fr has_type_from_lausanne has_type_from_tr].map do |spec|
                               Traject::TranslationMap.new(spec)
                             end.reduce(:merge)
        translation_map.translate_array!(accumulator)
      end
    end
  end
end
