# frozen_string_literal: true

module Macros
  # Macros for extracting language and derecting script from title
  module Princeton
    def princeton_title_and_lang
      lambda do |record, accumulator|
        begin
          title = record.dig('title').first.dig('@value')
          script = title.match?(/[aeiou]/) ? 'Latn' : 'Arab'
          language = get_title_language(record)
          language_and_script = "#{language}-#{script}"
        rescue
          title = record.dig('title').first
          script = title.match?(/[aeiou]/) ? 'Latn' : 'Arab'
          language_and_script = 'en'
        rescue
          # language = lang_map[record.dig('title').first.dig('@language').split('-').first.to_sym]
          title = 'Untitled'
          script = title.match?(/[aeiou]/) ? 'Latn' : 'Arab'
          language_and_script = 'none'
        end
        accumulator.replace([{ language: "#{language_and_script}", values: [title] }])
      end
    end

    def get_title_language(record)
      lang_map = { ara: 'ar',
                   fas: 'fa',
                   msa: 'ms',
                   ota: 'tr',
                   per: 'fa',
                   urdu: 'ur',
                   urd: 'ur'
                 } # other values needed here to map from incoming data to output expected?
      lang_map[record.dig('title').first.dig('@language').split('-').first.to_sym]
    end
  end
end
