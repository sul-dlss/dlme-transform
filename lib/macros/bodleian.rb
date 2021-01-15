# frozen_string_literal: true

module Macros
  # Macros for extracting values from Bodleian records
  module Bodleian
    def get_arabic_title(field)
      lambda do |record, accumulator|
        titles = []
        rec_title = record.dig(field) # look for the title
        if rec_title.present?
          if rec_title.include? "("
            titles << rec_title.split('(')[0]
            titles << rec_title.split('(')[-1].gsub(')', '')
          else
            titles << rec_title
          end
        end
        # rec_other_title = record.dig('other_titlestitle') # look for the title
        # if rec_other_title.present?
        #   if rec_other_title.include? "("
        #     titles << rec_other_title.split('(')[0]
        #     titles << rec_other_title.split('(')[-1].gsub(')', '')
        #   end
        # end
        titles.each do |val|
          lang = val.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'ar-Arab' : 'und-Latn'
          accumulator << { language: lang, values: [val] }
        end
      end
    end

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
  end
end
