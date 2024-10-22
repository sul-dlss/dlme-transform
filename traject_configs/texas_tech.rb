# frozen_string_literal: true

require 'dlme_debug_writer'
require 'dlme_json_resource_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/manchester'
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
extend Macros::Manchester
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

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', literal('texas-tech'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('texas-tech'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('texas-tech')

# Cho Required
to_field 'id', extract_json('.id'), flatten_array, at_index(0)
to_field 'cho_title', extract_json('.title'), flatten_array, lang('en')

# Cho Other
to_field 'cho_creator', extract_json('.creator'), flatten_array, lang('en')
to_field 'cho_date', extract_json('.date'), flatten_array, at_index(-1), lang('en')
to_field 'cho_date_range_hijri', extract_json('.date'), flatten_array, at_index(-1), parse_range, hijri_range
to_field 'cho_date_range_norm', extract_json('.date'), flatten_array, at_index(-1), parse_range
to_field 'cho_dc_rights', extract_json('.rights'), flatten_array, lang('en')
to_field 'cho_description', extract_json('.description'), flatten_array, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('.format'), flatten_array, at_index(0), lang('en')
to_field 'cho_format', extract_json('.format'), flatten_array, at_index(1), lang('en')
to_field 'cho_has_type', literal('Other Texts'), lang('en')
to_field 'cho_has_type', literal('Other Texts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.language'), flatten_array, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab') # Arabic value
to_field 'cho_language', extract_json('.language'), flatten_array, normalize_language, lang('en') # English value
to_field 'cho_publisher', extract_json('.publisher'), flatten_array, lang('en')
to_field 'cho_subject', extract_json('.subject'), flatten_array, lang('en')
to_field 'cho_type', extract_json('.type'), flatten_array, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.rights'), flatten_array, dlme_strip],
    'wr_format' => [literal('pdf')],
    'wr_id' => [extract_json('.identifier'), flatten_array, dlme_strip]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider',
  'agg_data_provider_collection',
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
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
# This may be used as an alternative to building 'cho_type_facet' directly,
# Don't use both.
each_record add_cho_type_facet
