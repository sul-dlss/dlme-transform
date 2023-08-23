# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
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

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', literal('shahre-farang'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('shahre-farang'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('shahre-farang')

# Cho Required
to_field 'id', column('id'), parse_csv, strip, gsub('http://shahrefarang.com/?p=', 'shahre-farang-'), append('fa')
to_field 'cho_title', column('title'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')

# Cho Other
to_field 'cho_creator', column('creator'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_date', column('date'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_date_range_norm', column('date'), parse_csv, strip, parse_range
to_field 'cho_date_range_hijri', column('date'), parse_csv, strip, parse_range, hijri_range
to_field 'cho_description', column('description'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Other Texts'), lang('en')
to_field 'cho_has_type', literal('Other Texts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('id'), parse_csv, strip
to_field 'cho_language', path_to_file, split('/'), at_index(2), gsub('_', '-'), normalize_language, lang('en')
to_field 'cho_language', path_to_file, split('/'), at_index(2), gsub('_', '-'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_subject', column('category'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('link'), strip],
    'wr_dc_rights' => [literal('© 2011-2020 شهرفرنگ - ShahreFarang')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('preview'), strip],
    'wr_dc_rights' => [literal('© 2011-2020 شهرفرنگ - ShahreFarang')]
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
  'agg_data_provider_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
