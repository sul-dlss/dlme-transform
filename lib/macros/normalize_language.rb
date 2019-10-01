# frozen_string_literal: true

module Macros
  # Macros for normalizing incoming metadata
  module NormalizeLanguage


    # Maps extracted language values to a series of tranlation maps
    # @example
    #   normalize_language => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def normalize_language
      # map = Traject::TranslationMap.new('not_found', 'languages')
      lambda do |record, accumulator|
        accumulator.map!{|str| str.downcase}
        translation_map = ['not_found', 'languages'].map do |spec|
          Traject::TranslationMap.new(spec)
        end.reduce(:merge)
        translation_map.translate_array!(accumulator)
          # s = Traject::TranslationMap.new('marc_languages')[str] #.translate_array!(accumulator)
          # v = Traject::TranslationMap.new('not_found')[s]
 #.translate_array!(accumulator)
        # }
      #   accumulator.map! do |val|
      #     v = val.downcase
        # Traject::TranslationMap.new('marc_languages').translate_array!(accumulator)
        # Traject::TranslationMap.new('not_found').translate_array!(accumulator)
      #   #     lang
      #     end
      #   # accumulator << TranslationMap.new('not_found', 'languages')
      # #     q = map[v]
      #   end
        # accumulator.map!{|str| str.downcase}
        # # accumulator.map! do |str|
        # #   str.downcase
        # translation_map('not_found', 'languages')
        # # end
      end
    end
  end
end
