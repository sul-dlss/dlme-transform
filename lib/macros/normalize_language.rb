# frozen_string_literal: true

module Macros
  # Macros for normalizing incoming metadata
  module NormalizeLanguage
    TRANSFORMS = %w[not_found
                    lang_from_downcased
                    lang_from_errors
                    lang_from_iso_639-1
                    lang_from_iso_639-2
                    lang_from_french
                    lang_from_turkish].freeze

    # Maps extracted language values to a series of tranlation maps
    # @example
    #   normalize_language => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def normalize_language
      lambda do |_record, accumulator|
        accumulator.map!(&:downcase)
        TRANSFORMS
          .map { |spec| Traject::TranslationMap.new(spec) }
          .reduce(:merge)
          .translate_array!(accumulator)
      end
    end
  end
end
