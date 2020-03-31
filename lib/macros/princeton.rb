# frozen_string_literal: true

module Macros
  # Macros for extracting language and derecting script from title
  module Princeton
    def language_rec
      lambda do |record, accumulator|
        script = accumulator.first.match?(/[aeiou]/) ? 'Latn' : 'Arab'
        accumulator.replace([{ language: "#{get_title_language(record)}-#{script}", values: accumulator.dup }])
      end
    end

    def get_title_language(record)
      lang_map = { ara: 'ar' }
      lang_map[record.dig('title').first.dig('@language').to_sym]
    end
  end
end
