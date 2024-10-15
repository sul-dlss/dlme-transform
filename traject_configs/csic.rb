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

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', literal('csic'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('csic'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('csic')

# CHO Required
to_field 'id', extract_json('.id'), flatten_array, at_index(1)
to_field 'cho_title', extract_json('.245_a'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_title', extract_json('.245_c'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')

# CHO Other
to_field 'cho_alternative', extract_json('.740_a'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.700_a'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_creator', extract_json('.100_a'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_creator', extract_json('.100_d'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_date', extract_json('.260_c'), flatten_array, dlme_strip, lang('und-Latn')
to_field 'cho_description', extract_json('.500_a'), flatten_array, dlme_strip, dlme_prepend('Annotations: '), lang('es')
to_field 'cho_description', extract_json('.520_a'), flatten_array, dlme_strip, dlme_prepend('Contents: '), lang('es')
to_field 'cho_description', extract_json('.563_a'), flatten_array, dlme_strip, dlme_prepend('Binding: '), lang('es')
to_field 'cho_description', extract_json('.546_b'), flatten_array, dlme_strip, dlme_prepend('Script: '), lang('es')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.300_a'), flatten_array, dlme_strip, lang('es')
to_field 'cho_extent', extract_json('.300_c'), flatten_array, dlme_strip, lang('es')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.546_a'), flatten_array, normalize_language, lang('en')
to_field 'cho_language', extract_json('.546_a'), flatten_array, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.541_a'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.600_a'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.600_t'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.600_x'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.600_v'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.630_a'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.630_x'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.650_a'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.650_x'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.650_z'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.651_a'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.651_x'), flatten_array, dlme_strip, lang('es')
to_field 'cho_subject', extract_json('.651_y'), flatten_array, dlme_strip, lang('es')
to_field 'cho_type', extract_json('.245_hh'), flatten_array, dlme_strip, lang('es')

# Agg Required
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [extract_json('.035_a'), flatten_array, dlme_strip, dlme_prepend('http://aleph.csic.es/imagenes/mad01/0006_PMSC/thumb/'), dlme_append('.jpg')])
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

# Agg Additional
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [extract_json('.856_u'), flatten_array, dlme_strip])
end

each_record convert_to_language_hash(
  'agg_data_provider_collection',
  'agg_data_provider_country',
  'agg_data_provider',
  'agg_provider_country',
  'agg_provider',
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
each_record add_cho_type_facet
