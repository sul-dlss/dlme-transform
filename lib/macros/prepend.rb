# frozen_string_literal: true

module Macros
  # Prepend helpers for traject mappings
  module Prepend
    # Returns if no value in field, else prepends prepend string in appropriate language
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  to_field 'cho_description', column('scribe'), arabic_script_lang_or_default('ar-Arab', 'en'), return_or_prepend('Scribe: ', 'الكاتب: ')
    def intelligent_prepend(prepend_string_en, prepend_string_translation)
      lambda do |_record, accumulator|
        return if accumulator.empty?

        accumulator.filter_map { |n| n[:values].map { |s| n[:language] == 'en' ? s.prepend(prepend_string_en) : s.prepend(prepend_string_translation) } }
      end
    end
  end
end