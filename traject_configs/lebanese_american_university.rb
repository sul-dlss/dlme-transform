# frozen_string_literal: true

require 'dlme_debug_writer'
require 'dlme_json_resource_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/timestamp'
require 'macros/transformation'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::Timestamp
extend Macros::Transformation
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'allow_duplicate_values', false
  provide 'allow_nil_values', false
  provide 'allow_empty_fields', false
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('lau-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('lau-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('lau-')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_json('.id'), flatten_array, dlme_strip, dlme_gsub('/manifest.json', ''), dlme_gsub('https://cdm16366.contentdm.oclc.org/iiif/', '')
to_field 'cho_title', extract_json('.title'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')

# Cho Other
to_field 'cho_contributor', extract_json('.contributors'), flatten_array, dlme_split('--'), dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_creator', extract_json('.creator'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date', extract_json('.date'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_hijri', extract_json('.date'), flatten_array, dlme_strip, auc_date_range, hijri_range
to_field 'cho_date_range_norm', extract_json('.date'), flatten_array, dlme_strip, auc_date_range
to_field 'cho_description', extract_json('.description'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_edm_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('lau-'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('lau-'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.dimension'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
# Using collection identifier to map to has type since type values are vague
to_field 'cho_has_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('lau-'), normalize_has_type, lang('en')
to_field 'cho_has_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('lau-'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.language'), flatten_array, dlme_split(','), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.language'), flatten_array, dlme_split(','), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_subject', extract_json('.index-terms'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', extract_json('.type'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [literal('To inquire about permissions or reproductions, contact the Rare Books and Special Collections Library, The American University in Cairo at +20.2.2615.3676 or rbscl-ref@aucegypt.edu.')],
    'wr_format' => [extract_json('.iiif_format'), flatten_array, at_index(0)],
    'wr_id' => [extract_json('.resource'), flatten_array],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, at_index(0)]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [literal('To inquire about permissions or reproductions, contact the Rare Books and Special Collections Library, The American University in Cairo at +20.2.2615.3676 or rbscl-ref@aucegypt.edu.')],
    'wr_format' => [extract_json('.iiif_format'), flatten_array, at_index(0)],
    'wr_id' => [extract_json('.resource'), flatten_array, dlme_gsub('/full/full/0/default.jpg', '/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, at_index(0)]
  )
end
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

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
