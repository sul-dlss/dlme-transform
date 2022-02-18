# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/aub'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::AUB
extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
end

to_field 'agg_data_provider_collection', collection
to_field 'dlme_collection', literal('aub-aco'), translation_map('dlme_collection_from_provider_id'), lang('en')
to_field 'dlme_collection', literal('aub-aco'), translation_map('dlme_collection_from_provider_id'), translation_map('dlme_collection_ar_from_en'), lang('ar-Arab')

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Cho Required
to_field 'id', column('id'), strip, parse_csv
to_field 'cho_title', json_title_or('title', 'description'), strip, parse_csv, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), default('Untitled', 'بدون عنوان')

# Cho Other
to_field 'cho_creator', column('creator'), strip, parse_csv, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_date', column('date'), strip, parse_csv, lang('en')
to_field 'cho_date_range_hijri', column('date'), strip, parse_csv, parse_range, hijri_range
to_field 'cho_date_range_norm', column('date'), strip, parse_csv, parse_range
to_field 'cho_dc_rights', column('rights'), strip, parse_csv, lang('en')
to_field 'cho_description', column('description'), strip, parse_csv, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_edm_type', literal('Image'), lang('en')
to_field 'cho_edm_type', literal('Image'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Posters'), lang('en')
to_field 'cho_has_type', literal('Posters'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('identifier'), strip, parse_csv
to_field 'cho_language', column('language'), strip, parse_csv, split(';'),
         split(','), strip, normalize_language, lang('en')
to_field 'cho_language', column('language'), strip, parse_csv, split(';'),
         split(','), strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_publisher', column('publisher'), strip, parse_csv, lang('en')
to_field 'cho_spatial', column('coverage'), strip, parse_csv, lang('en')
to_field 'cho_subject', column('subject'), strip, parse_csv, lang('en')
to_field 'cho_type', column('type'), strip, parse_csv, arabic_script_lang_or_default('ar-Arab', 'und-Latn')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [column('rights'), strip, parse_csv],
    'wr_edm_rights' => [literal('CC BY-ND: https://creativecommons.org/licenses/by-nd/4.0/')],
    'wr_id' => [column('identifier'), strip, parse_csv]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [column('rights'), strip, parse_csv],
    'wr_edm_rights' => [literal('CC BY-ND: https://creativecommons.org/licenses/by-nd/4.0/')],
    'wr_id' => [column('id'), strip, parse_csv, prepend('https://libraries.aub.edu.lb/xtf/data/posters/'), append('/thumb.jpg')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider',
  'agg_data_provider_country',
  'agg_provider',
  'agg_provider_country',
  'cho_alternative',
  'cho_contributor',
  'cho_coverage',
  'cho_creator',
  'cho_date',
  'cho_dc_rights',
  'cho_description',
  'cho_edm_type',
  'cho_extent',
  'cho_format',
  'cho_has_part',
  'cho_has_type',
  'cho_is_part_of',
  'cho_language',
  'cho_medium',
  'cho_provenance',
  'cho_publisher',
  'cho_relation',
  'cho_source',
  'cho_spatial',
  'cho_subject',
  'cho_temporal',
  'cho_title',
  'cho_type',
  'dlme_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
