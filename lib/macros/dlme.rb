# frozen_string_literal: true

module Macros
  # DLME helpers for traject mappings
  module DLME
    NS = {
      dc: 'http://purl.org/dc/elements/1.1/',
      mods: 'http://www.loc.gov/mods/v3',
      oai: 'http://www.openarchives.org/OAI/2.0/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      tei: 'http://www.tei-c.org/ns/1.0'
    }.freeze
    private_constant :NS

    # Returns the data provider as specified in the ++agg_data_provider++ field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  data_provider => "SALT Galata"
    def data_provider
      from_settings('agg_data_provider')
    end

    # Returns the Ara lang data provider as specified in the ++agg_data_provider_ar++
    # field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  data_provider => "مكتبات ستانفورد"
    def data_provider_ar
      from_settings('agg_data_provider_ar')
    end

    # Returns the data provider country specified in ++agg_data_provider_country++ field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  data_provider_country => "France"
    def data_provider_country
      from_settings('agg_data_provider_country')
    end

    # Returns the Ara lang data provider country specified in ++agg_data_provider_country_ar++
    # field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  data_provider_country => "فرنسا"
    def data_provider_country_ar
      from_settings('agg_data_provider_country_ar')
    end

    # Override the traject default method, passing two values-one English, one Arabic-instead of none
    # and adding language keys. Cannot use this method in conjunction with the lang method. Call them
    # on seperate lines.
    # @example
    #  # to_field 'cho_title', extract_tei("tei:title"), lang('en')
    #  # to_field 'cho_title', extract_tei("tei:title"), default('Untitled', 'بدون عنوان')
    def default(default_en, default_ar)
      lambda do |_rec, acc|
        if acc.all?(
          &:blank?
        )
          acc.replace([{ language: 'en', values: [default_en] },
                       { language: 'ar-Arab', values: [default_ar] }])
        end
      end
    end

    # Create an identifier that can be used in case none is encoded in the record.
    # It will first try to take it from the ++command_line.filename++ setting and
    # if that is not available, from the `identifier` setting.
    # @return [String] a record identifier
    # @example
    #  # when settings contains: "command_line.filename"=>"data/penn/schoenberg/data/ljs407.xml"
    #
    #  default_identifier(context) => 'ljs407'
    def default_identifier(context)
      identifier = if context.settings.key?('command_line.filename')
                     context.settings.fetch('command_line.filename')
                   elsif context.settings.key?('identifier')
                     context.settings.fetch('identifier')
                   end
      File.basename(identifier, File.extname(identifier)) if identifier.present?
    end

    # Returns the given identifier prefixed with the ++inst_id++  as specified in ++config/metadata_mapping.json++
    # @param [Traject::Indexer::Context] context
    # @param [String] identifier
    # @return [String] a prefixed record identifier
    # @example
    #  # when settings contains: "inst_id"=>"salt"
    #
    #  identifier_with_prefix(context, '123') => "salt_123"
    def identifier_with_prefix(context, identifier)
      return identifier unless context.settings.key?('inst_id')

      prefix = context.settings.fetch('inst_id') + '_'

      if identifier.start_with? prefix
        identifier
      else
        prefix + identifier
      end
    end

    # Assign a language key to extracted value. Raise an exception if assigned value not in config/settings.yml.
    def lang(bcp47_string)
      raise "#{bcp47_string} is not an acceptable BCP47 language code" unless
        Settings.acceptable_bcp47_codes.include?(bcp47_string)

      lambda do |_record, accumulator, _context|
        accumulator.replace([{ language: bcp47_string, values: accumulator.dup }]) unless accumulator&.empty?
      end
    end

    # Take only the last value from the accumulator
    def last
      lambda do |_rec, acc|
        acc.slice!(0, acc.length - 1)
      end
    end

    # Returns the provider as specified in the ++agg_provider++ field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  provider => "Bibliothèque nationale de France"
    def provider
      from_settings('agg_provider')
    end

    # Returns the Ara lang provider as specified in the ++agg_provider_ar++
    # field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  provider => "أرشيف ملصق فلسطين"
    def provider_ar
      from_settings('agg_provider_ar')
    end

    # Returns the provider country as specified in the ++agg_provider_country++ field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  provider_country => "France"
    def provider_country
      from_settings('agg_provider_country')
    end

    # Returns the Ara lang provider country as specified in the ++agg_provider_country_ar++
    # field of ++config/metadata_mapping.json++
    # @return [Proc] a proc that traject can call for each record
    # @example
    #  provider_country => "الولايات المتحدة الامريكيه"
    def provider_country_ar
      from_settings('agg_provider_country_ar')
    end

    # Returns if no value in field, else prepends prepend string
    def return_or_prepend(xpath, prepend_string)
      lambda do |record, accumulator|
        field_value = record.xpath(xpath, NS).map(&:text).first
        return unless field_value.present?

        accumulator.replace(["#{prepend_string} #{field_value}".gsub(/\s+/, ' ').strip])
      end
    end
  end
end
