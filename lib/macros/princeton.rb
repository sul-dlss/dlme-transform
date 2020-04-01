# frozen_string_literal: true

module Macros
  # Macros for extracting language and derecting script from title
  module Princeton
    def princeton_title_and_lang
      lambda do |record, accumulator|
        rec_title = record.dig('title') # look for the title
        title_and_language = rec_title ? get_title_and_language(rec_title.first) : { language: 'none', values: ['Untitled'] }
        accumulator.replace([title_and_language])
      end
    end

    private

    def get_title_and_language(rec_title)
      if rec_title.class == Hash # if we have a value/lang pair in the title field, we can auto set the language
        title = rec_title.dig('@value') # grab the title from @value attribute
        language = map_language_value(rec_title) # get the language from the title
        script = title.match?(/[aeiou]/) ? 'Latn' : 'Arab'
        { language: "#{language}-#{script}", values: [title] }
      else # we do not have a value/lang pair in the title, so have to assume english
        { language: 'en', values: [rec_title] }
      end
    end

    def map_language_value(record_title)
      lang_map = { ara: 'ar',
                   fas: 'fa',
                   msa: 'ms',
                   ota: 'tr',
                   per: 'fa',
                   urdu: 'ur',
                   urd: 'ur' } # add other values here as needed to map from incoming lang data to output expected
      lang_map[record_title.dig('@language').split('-').first.to_sym]
    end
  end
end
