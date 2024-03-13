# frozen_string_literal: true

module Macros
  # Prepend helpers for traject mappings
  module Split
    # Returns if no value in field, else splits on parameter
    # traject's split macro fails on nil
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  to_field 'cho_description', column('scribe'), arabic_script_lang_or_default('ar-Arab', 'en'), return_or_prepend('Scribe: ', 'الكاتب: ')
    def dlme_split(split_string)
      lambda do |_record, accumulator|
        return if accumulator.compact.blank?

        accumulator << accumulator.map{|s|s.split(split_string)}
      end
    end
  end
end
