# frozen_string_literal: true

require 'byebug'

module Macros
  # Macros for extracting Stanford Specific MODS values from Nokogiri documents
  module Princeton

    def get_language_rec
      lambda do |_record, accumulator|
        if accumulator.first.match?(/[aeiou]/)
          script = 'Latn'
        else
          script = 'Arab'
        end
        accumulator.replace([{ language: "ar-#{script}", values: accumulator.dup }])
      end
    end


    # raise "#{bcp47_string} is not an acceptable BCP47 language code" unless
    # Settings.acceptable_bcp47_codes.include?(bcp47_string)

  lambda do |_record, accumulator, _context|
    accumulator.replace([{ language: bcp47_string, values: accumulator.dup }]) unless accumulator&.empty?
  end

    def get_language
      lang_map = { ara: 'ar' }
      lambda do |record, accumulator, context|
        title = record.dig('title').first.dig('@value')
        lang = lang_map[record.dig('title').first.dig('@language')]
        if title.match?(/[aeiou]/)
          script = 'Latn'
        else
          script = 'Arab'
        end
        accumulator << "#{lang_map[:ara]}-#{script}"
      end
    end

  end
end
