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

# File path
to_field 'dlme_source_file', path_to_file

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection_id', literal('ifpo-photographs')
to_field 'agg_data_provider_collection', literal('ifpo-photographs'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection', literal('ifpo-photographs'), translation_map('agg_collection_from_provider_id'), lang('en')

# Cho Required
to_field 'id', extract_json('.id'), flatten_array, dlme_split('-'), last
to_field 'cho_title', extract_json('.title'), flatten_array, lang('fr')

# Cho Other
to_field 'cho_alternative', extract_json('.title_en'), flatten_array, lang('en')
to_field 'cho_contributor', extract_json('.contributor'), flatten_array, lang('en')
to_field 'cho_coverage', extract_json('.coverage'), flatten_array, lang('en')
to_field 'cho_creator', extract_json('.creator'), flatten_array, lang('en')
to_field 'cho_date', extract_json('.date'), flatten_array, lang('en')
to_field 'cho_date_range_norm', extract_json('.date'), flatten_array, dlme_split('-'), first_only, parse_range
to_field 'cho_date_range_hijri', extract_json('.date'), flatten_array, dlme_split('-'), first_only, parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('.rights'), flatten_array, lang('en')
to_field 'cho_description', extract_json('.description_en'), flatten_array, lang('en')
to_field 'cho_description', extract_json('.description_fr'), flatten_array, lang('fr')
to_field 'cho_edm_type', extract_json('.type'), flatten_array, last, transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), lang('ar-Arab') # Arabic value
to_field 'cho_edm_type', extract_json('.type'), flatten_array, last, transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('edm_type_from_has_type'), lang('en') # English value
to_field 'cho_has_type', extract_json('.type'), flatten_array, last, transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('has_type_ar_from_en'), lang('ar-Arab') # Arabic value
to_field 'cho_has_type', extract_json('.type'), flatten_array, last, transform(&:downcase), translation_map('has_type_from_contributor'), lang('en') # English value
to_field 'cho_identifier', extract_json('.identifier'), flatten_array
to_field 'cho_language', extract_json('.language'), flatten_array, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.language'), flatten_array, normalize_language, lang('en')
to_field 'cho_publisher', extract_json('.publisher'), flatten_array, lang('en')
to_field 'cho_source', extract_json('.source'), flatten_array, lang('en')
to_field 'cho_subject', extract_json('.subject_ar'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_subject', extract_json('.subject_en'), flatten_array, lang('en')
to_field 'cho_subject', extract_json('.subject_fr'), flatten_array, lang('fr')
to_field 'cho_type', extract_json('.type'), flatten_array, last, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.id'), flatten_array, dlme_split(':'), last, dlme_gsub('v1', ''), dlme_prepend('https://medihal.archives-ouvertes.fr/')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.id'), flatten_array, dlme_split(':'), last, dlme_gsub('v1', ''), dlme_prepend('https://medihal.archives-ouvertes.fr/'), dlme_append('/thumb')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

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
