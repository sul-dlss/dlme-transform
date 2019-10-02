# frozen_string_literal: true

module Macros
  # Macros for normalizing incoming metadata
  module NormalizeLanguage
    # Maps extracted language values to a series of tranlation maps
    # @example
    #   normalize_language => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def normalize_language
      lambda do |_record, accumulator|
        accumulator.map!(&:downcase)
        translation_map = %w[not_found languages marc_languages
                             turkish-languages iso_639-1 iso_639-2
                             iso_639-3 auc-languages-errors].map do |spec|
          Traject::TranslationMap.new(spec)
        end.reduce(:merge)
        translation_map.translate_array!(accumulator)
      end
    end
  end
end
