# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/iiif'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/transformation'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::IIIF
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
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

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('uab-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('uab-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('uab-')

# CHO Required
to_field 'id', extract_json('.id'), dlme_gsub('oai:alma', '')
to_field 'cho_title', extract_json('.245_a'), flatten_array, dlme_split('/'), dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')

# CHO Other
to_field 'cho_creator', extract_json('.100_a'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_dc_rights', extract_json('.540_a'), flatten_array, lang('en')
to_field 'cho_description', extract_json('.520_a'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('.856_q'), flatten_array, lang('en')
to_field 'cho_is_part_of', extract_json('.787_n'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_language', extract_json('.546_a'), flatten_array, dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.546_a'), flatten_array, dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_subject', extract_json('.653_a'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
# uab requested to translated LoC urls to user-facing type values
to_field 'cho_type', extract_json('.655_a'), flatten_array, translation_map('type_from_loc'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.id'), dlme_split(':'), at_index(-1), dlme_prepend('https://uab.primo.exlibrisgroup.com/discovery/fulldisplay?docid=alma'), dlme_append('&context=L&vid=01AL_UALB:UAB_Libraries&lang=en&adaptor=Local%20Search%20Engine')],
    'wr_is_referenced_by' => [extract_json('.id'), dlme_split(':'), at_index(-1), dlme_gsub('https://iiif.library.uab.edu/iiif/2/', 'https://iiif.library.uab.edu/'), append('/manifest')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.object[0]')],
    'wr_is_referenced_by' => [extract_json('.object[0]'), dlme_split('/full/'), at_index(0), dlme_gsub('https://iiif.library.uab.edu/iiif/2/', 'https://iiif.library.uab.edu/'), append('/manifest')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

# Ignored Fields
## none

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
