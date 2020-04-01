# frozen_string_literal: true

module Macros
  # Macros for extracting language and derecting script from title
  module Princeton
    def princeton_title_and_lang
      lambda do |record, accumulator|
        rec_title = record.dig('title') # look for the title
        if rec_title # we have a title
          first_rec_title = rec_title.first # just use the first title found
          if first_rec_title.class == Hash # if we have a value/lang pair in the title field, we can auto set the language
            title = first_rec_title.dig('@value') # grab the title from @value attribute
            language = get_title_language(first_rec_title) # get the language from the title
            script = title.match?(/[aeiou]/) ? 'Latn' : 'Arab'
            language_and_script = "#{language}-#{script}"
          else # we do not have a value/lang pair in the title, so have to assume english
            title = first_rec_title # grab the title
            language_and_script = 'en'
          end
        else # we couldn't find any title at all, use defaults
          title = 'Untitled'
          language_and_script = 'none'
        end
        accumulator.replace([{ language: language_and_script, values: [title] }])
      end
    end

    def get_title_language(record_title)
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
