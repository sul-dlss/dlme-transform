# frozen_string_literal: true

module Macros
  # Macros for extracting Stanford Specific MODS values from Nokogiri documents
  module Princeton

    def get_language(record)
      lang_map = { ara: 'ar' }
      title = record.dig('title').first.dig('@value')
      lang = lang_map[record.dig('title').first.dig('@language')]
      if title.match?(/[aeiou]/)
        script = 'Latn'
      else
        script = 'Arab'
      end
      "#{lang_map[:ara]}-#{script}"
    end

    # def get_language
    #   lang_map = { ara: 'ar' }
    #   lambda do |record, accumulator, context|
    #     title = record.dig('title').first.dig('@value')
    #     lang = lang_map[record.dig('title').first.dig('@language')]
    #     if title.match?(/[aeiou]/)
    #       script = 'Latn'
    #     else
    #       script = 'Arab'
    #     end
    #     "#{lang_map[:ara]}-#{script}"
    #   end
    # end

  end
end
