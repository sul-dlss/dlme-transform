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

# Collection
to_field 'agg_data_provider_collection', literal('Nashriyah: digital Iranian history (Manchester)'), lang('en')
to_field 'agg_data_provider_collection', literal('پآرشیو آنلاین نشریات دانشگاه منچستر (منچستر)'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('manchester-nashriyah')

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', extract_json('.id'), flatten_array, dlme_gsub('oai:N/A:Manchester~', '')
to_field 'cho_title', extract_json('.title'), flatten_array, at_index(0), dlme_default('Untitled'), lang('und-Arab')
to_field 'cho_title', extract_json('.title'), flatten_array, at_index(1), lang('fa-Latn')
to_field 'cho_title', extract_json('.title'), flatten_array, at_index(2), lang('en')

# CHO Other
to_field 'cho_creator', extract_json('.creator'), flatten_array, lang('fa-Arab')
to_field 'cho_date', extract_json('.date'), flatten_array, dlme_strip, lang('fa-Arab')
to_field 'cho_date_range_hijri', extract_json('.date'), flatten_array, manchester_solar_hijri_range, hijri_range
to_field 'cho_date_range_norm', extract_json('.date'), flatten_array, manchester_solar_hijri_range
to_field 'cho_dc_rights', extract_json('.rights'), flatten_array, lang('en')
to_field 'cho_description', extract_json('.description'), flatten_array, lang('en')
to_field 'cho_edm_type', extract_json('.type'), flatten_array, at_index(-1), dlme_transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('edm_type_from_has_type'), lang('en') # English value
to_field 'cho_edm_type', extract_json('.type'), flatten_array, at_index(-1), dlme_transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), lang('ar-Arab') # Arabic value
to_field 'cho_format', extract_json('.format'), flatten_array, lang('en')
to_field 'cho_has_type', extract_json('.type'), flatten_array, last, dlme_transform(&:downcase), translation_map('has_type_from_contributor'), lang('en') # English value
to_field 'cho_has_type', extract_json('.type'), flatten_array, last, dlme_transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('has_type_ar_from_en'), lang('ar-Arab') # Arabic value
to_field 'cho_identifier', extract_json('.identifier'), flatten_array, last
to_field 'cho_language', literal('Persian'), lang('en')
to_field 'cho_language', literal('Persian'), translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_spatial', literal('Iran'), lang('en')
to_field 'cho_spatial', literal('إيران'), lang('ar-Arab')
to_field 'cho_type', extract_json('.type'), flatten_array, last, lang('en')

# Agg
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_edm_rights', literal('http://creativecommons.org/licenses/by-nc-sa/4.0')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [literal('http://creativecommons.org/licenses/by-nc-sa/4.0')],
    'wr_id' => [extract_json('.id'), flatten_array, dlme_strip, dlme_gsub('oai:N/A:', 'https://luna.manchester.ac.uk/luna/servlet/detail/')],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip, dlme_gsub('oai:N/A:', 'https://luna.manchester.ac.uk/luna/servlet/iiif/m/'), dlme_append('/manifest')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [literal('http://creativecommons.org/licenses/by-nc-sa/4.0')],
    'wr_id' => [extract_json('.identifier'), flatten_array, at_index(1)],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip, dlme_gsub('oai:N/A:', 'https://luna.manchester.ac.uk/luna/servlet/iiif/m/'), dlme_append('/manifest')]
  )
end

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
