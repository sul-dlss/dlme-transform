# frozen_string_literal: true

module Macros
  # DLME helpers for traject mappings
  module LanguageExtraction
    NS = {
      tei: 'http://www.tei-c.org/ns/1.0'
    }.freeze
    private_constant :NS

    # Hash for converting normalized language values to BCP 47 values
    TO_BCP47 = {
      ara: 'ar-Arab',
      per: 'fa-Arab',
      syc: 'syc'
    }.freeze
    private_constant :TO_BCP47

    TEI_LOWER_PREFIX = '/*/*/*/tei:teiheader/tei:filedesc/tei:sourcedesc/tei:msdesc/tei:mscontents'
    private_constant :TEI_LOWER_PREFIX

    # Returns the value extracted by 'to_field' reformated as a hash with accompanying BCP47 language code.
    # Should only be used to differentiate between an Arabic script language '-Arab' and a Latin script
    # language '-Latn'.
    # @return [Proc] a proc that traject can call for each record
    # @example
    # arabic_script_lang_or_default('ar-Arab', 'en') => {'ar-Arab': ['من كتب محمد بن محمد الكبسي. لقطة رقم (1).']}
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    def arabic_script_lang_or_default(arabic_script_lang, default)
      lambda do |_record, accumulator|
        if accumulator
          ar_values = []
          default_values = []
          accumulator.each do |val|
            val = translate_role_to_ar(val)
            lang_code = val.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? arabic_script_lang : default
            ar_values << val if lang_code == arabic_script_lang
            default_values << val if lang_code == default
          end
        end
        if ar_values.present? && default_values.present?
          accumulator.replace([{ language: arabic_script_lang, values: ar_values }])
          accumulator << { language: default, values: default_values } if default_values.present?
        elsif ar_values.present? && default_values.empty?
          accumulator.replace([{ language: arabic_script_lang, values: ar_values }])
        elsif ar_values.empty? && default_values.present?
          accumulator.replace([{ language: default, values: default_values }])
        end
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength

    # Returns the value extracted by 'to_field' reformated as a hash with accompanying BCP47 language code.
    # Should only be used to differentiate between an Hebrew script language and a Latin script
    # language '-Latn'.
    # @return [Proc] a proc that traject can call for each record
    # @example
    # arabic_script_lang_or_default('he', 'en') => {'he': ['ספר בחכמות הרפואות']}
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    def hebrew_script_lang_or_default(hebrew_script_lang, default)
      lambda do |_record, accumulator|
        if accumulator
          he_values = []
          default_values = []
          accumulator.each do |val|
            val = translate_role_to_ar(val)
            lang_code = val.match?(/[תשרקץצףפעסןנםמלךכיטחזוהדגבא]/) ? hebrew_script_lang : default
            he_values << val if lang_code == hebrew_script_lang
            default_values << val if lang_code == default
          end
        end
        if he_values.present? && default_values.present?
          accumulator.replace([{ language: hebrew_script_lang, values: he_values }])
          accumulator << { language: default, values: default_values }
        elsif he_values.present?
          accumulator.replace([{ language: hebrew_script_lang, values: he_values }])
        elsif default_values.present?
          accumulator.replace([{ language: default, values: default_values }])
        end
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength

    # Returns the value extracted by 'to_field' reformated as a hash with accompanying BCP47 language code.
    # Caution: assumes the language of the metadata field is the same as the main language of the text.
    # Works on cases where the element names are downcased instead of camel cased.
    # @return [Proc] a proc that traject can call for each record
    # @example
    # naive_language_extractor => {'ar-Arab': ['من كتب محمد بن محمد الكبسي. لقطة رقم (1).']}
    def tei_lower_resource_language
      lambda do |record, accumulator|
        language = record.xpath("#{TEI_LOWER_PREFIX}/tei:textlang/@mainlang", tei: NS[:tei])
                         .text
        extracted_string = accumulator[0]
        accumulator.replace([{ language: TO_BCP47[:"#{language}"], values: [extracted_string] }]) if extracted_string
      end
    end

    # Returns the provided value with the english role translated to arabic if found
    def translate_role_to_ar(val)
      role_name = val.match(/(\()(\w+)(\))/)&.to_a&.at(2)
      return val unless role_name

      role_ar_map = Traject::TranslationMap.new('role_ar_from_en')
      translated_role = role_ar_map[role_name]
      return val unless translated_role

      val.gsub(role_name, translated_role)
    end
  end
end
