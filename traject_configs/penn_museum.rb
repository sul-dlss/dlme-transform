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

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('penn-museum-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('penn-museum-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('penn-museum-')

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', extract_json('emuIRN'), flatten_array, transform(&:to_s), dlme_prepend('penn-egyptian-')
to_field 'cho_title', extract_json('.object_name'), flatten_array, dlme_default('Untitled'), dlme_split('|'), lang('en')

# CHO Other
to_field 'cho_coverage', extract_json('.culture'), flatten_array, dlme_split('|'), lang('en')
to_field 'cho_creator', extract_json('.creator'), flatten_array, lang('en')
to_field 'cho_date', extract_json('.date_made'), transform(&:to_s), flatten_array, lang('en')
to_field 'cho_date', extract_json('.date_made_early'), transform(&:to_s), flatten_array, lang('en')
to_field 'cho_date', extract_json('.date_made_late'), transform(&:to_s), flatten_array, lang('en')
to_field 'cho_date_range_norm', csv_or_json_date_range('date_made_early', 'date_made_late')
to_field 'cho_date_range_hijri', csv_or_json_date_range('date_made_early', 'date_made_late'), hijri_range
to_field 'cho_description', extract_json('.description'), flatten_array, lang('en')
to_field 'cho_description', extract_json('.technique'), flatten_array, dlme_split('|'), lang('en')
to_field 'cho_edm_type', extract_json('.object_name'), flatten_array, normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.object_name'), flatten_array, normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.measurement_height'), flatten_array, transform(&:to_s), lang('en')
to_field 'cho_extent', extract_json('.measurement_length'), flatten_array, transform(&:to_s), lang('en')
to_field 'cho_extent', extract_json('.measurement_outside_diameter'), flatten_array, transform(&:to_s), lang('en')
to_field 'cho_extent', extract_json('.measurement_tickness'), flatten_array, transform(&:to_s), lang('en')
to_field 'cho_extent', extract_json('.measurement_unit'), flatten_array, lang('en')
to_field 'cho_extent', extract_json('.measurement_width'), flatten_array, transform(&:to_s), lang('en')
to_field 'cho_has_type', extract_json('.object_name'), flatten_array, normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.object_name'), flatten_array, normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.emuIRN'), transform(&:to_s), flatten_array
to_field 'cho_medium', extract_json('.material'), dlme_split('|'), flatten_array, lang('en')
to_field 'cho_provenance', extract_json('.accession_credit_line'), flatten_array, lang('en')
to_field 'cho_source', extract_json('.object_number'), flatten_array, lang('en')
to_field 'cho_source', extract_json('.other_numbers'), flatten_array, dlme_split('|'), lang('en')
to_field 'cho_spatial', extract_json('.provenience'), flatten_array, dlme_split('|'), lang('en')
to_field 'cho_subject', extract_json('.iconography'), flatten_array, lang('en')
to_field 'cho_temporal', extract_json('.period'), flatten_array, dlme_split('|'), lang('en')
to_field 'cho_type', extract_json('.object_name'), flatten_array, dlme_split('|'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('emuIRN'), flatten_array, transform(&:to_s), dlme_prepend('https://www.penn.museum/collections/object/')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.thumbnail'), flatten_array, dlme_gsub('collections/assets/800', 'collections/assets/300')])
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
