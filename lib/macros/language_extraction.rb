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
    # Should only be used when metadata is known to be either Arabic in Arabic script or none.
    # Any other values will not parse correctly.
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  naive_language_extractor => {'ar-Arab': ['من كتب محمد بن محمد الكبسي. لقطة رقم (1).']}
    def arabic_or_none
      lambda do |_record, accumulator|
        extracted_string = accumulator[0]
        if extracted_string
          script = extracted_string.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'ar-Arab' : 'none'
          accumulator.replace([{ language: script.to_s, values: [extracted_string] }])
        end
      end
    end

    def arabic_or_default(default = 'none')
      lambda do |_record, accumulator|
        accumulator.map! do |val|
          script = val.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'ar-Arab' : default
          { language: script.to_s, values: [val] }
        end
      end
    end

    # Returns the value extracted by 'to_field' reformated as a hash with accompanying BCP47 language code.
    # Should only be used when metadata is known to be either Arabic in Arabic script or none.
    # Any other values will not parse correctly.
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  naive_language_extractor => {'ar-Arab': ['من كتب محمد بن محمد الكبسي. لقطة رقم (1).']}
    def arabic_or_und_latn
      lambda do |_record, accumulator|
        extracted_string = accumulator[0]
        if extracted_string
          script = extracted_string.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'ar-Arab' : 'und-Latn'
          accumulator.replace([{ language: script.to_s, values: [extracted_string] }])
        end
      end
    end

    # Returns the value extracted by 'to_field' reformated as a hash with accompanying BCP47 language code.
    # Should only be used when metadata is known to be either Arabic in Arabic script or English.
    # Any other values will not parse correctly.
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  naive_language_extractor => {'ar-Arab': ['من كتب محمد بن محمد الكبسي. لقطة رقم (1).']}
    def naive_language_extractor
      lambda do |_record, accumulator|
        extracted_string = accumulator[0]
        if extracted_string
          script = extracted_string.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'ar-Arab' : 'en'
          accumulator.replace([{ language: script.to_s, values: [extracted_string] }])
        end
      end
    end

    # Returns the value extracted by 'to_field' reformated as a hash with accompanying BCP47 language code.
    # Should only be used when metadata is known to be either Persian in Arabic script or an unpredictable language.
    # Any other values will not parse correctly.
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  persian_or_none => {'fa-Arab': ['نظامنامۀ مقياسات']}
    def persian_or_none
      lambda do |_record, accumulator|
        extracted_string = accumulator[0]
        if extracted_string
          script = extracted_string.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'fa-Arab' : 'none'
          accumulator.replace([{ language: script.to_s, values: [extracted_string] }])
        end
      end
    end

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

    # Returns the value extracted by 'to_field' reformated as a hash with accompanying BCP47 language code.
    # Should only be used when metadata is known to be either Arabic in Arabic script or none.
    # Any other values will not parse correctly.
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  naive_language_extractor => {'ar-Arab': ['من كتب محمد بن محمد الكبسي. لقطة رقم (1).']}
    def und_arabic_or_syriac
      lambda do |_record, accumulator|
        extracted_string = accumulator[0]
        if extracted_string
          script = extracted_string.match?(/[ضصثقفغعهخحمنتالبيسشظطذدزرو]/) ? 'und-Arab' : 'syc'
          accumulator.replace([{ language: script.to_s, values: [extracted_string] }])
        end
      end
    end
  end
end
