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
        return if accumulator.first.nil?

        accumulator.filter_map { |n| n[:values].map { |s| n[:language] == 'en' ? s.prepend(prepend_string_en) : s.prepend(prepend_string_translation) } }
      end
    end

    # Returns if no value in field, else prepends prepend string in appropriate language
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  to_field 'cho_description', column('scribe'), arabic_script_lang_or_default('ar-Arab', 'en'), return_or_prepend('Scribe: ', 'الكاتب: ')
    def dlme_prepend(prepend_string)
      lambda do |_record, accumulator|
        return if accumulator.compact.empty?

        values = []
        accumulator.each do |val|
          values << val
        end

        accumulator.replace(["#{prepend_string}#{values.join(', ')}"]) if values.present?
      end
    end
  end
end
