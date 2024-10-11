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

to_field 'agg_data_provider_collection', literal('yale-babylon'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('yale-babylon'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('yale-babylon')

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', extract_json('.id'), flatten_array, dlme_transform(&:to_s)
to_field 'cho_title', extract_json('.title'), flatten_array, dlme_default('Untitled'), lang('en')

# CHO Other
to_field 'cho_aat_material', extract_json('.era'), flatten_array, dlme_split(';'), dlme_split(':'), dlme_split('/'), dlme_strip, dlme_transform(&:downcase), translation_map('getty_aat_material_from_contributor'), lang('en')
to_field 'cho_aat_material', extract_json('.era'), flatten_array, dlme_split(':'), dlme_strip, dlme_transform(&:downcase), translation_map('getty_aat_material_from_contributor'), translation_map('getty_aat_material_ar_from_en'), lang('ar-Arab')
to_field 'cho_dc_rights', literal('http://creativecommons.org/publicdomain/zero/1.0/'), lang('en')
to_field 'cho_description', extract_json('.type'), flatten_array, lang('en')
to_field 'cho_edm_type', extract_json('.format'), flatten_array, dlme_split(';'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.format'), flatten_array, dlme_split(';'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', extract_json('.format'), flatten_array, dlme_split(';'), normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.format'), flatten_array, dlme_split(';'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.callnumber'), flatten_array, dlme_prepend('Catalog Number: ')
to_field 'cho_identifier', extract_json('.type'), flatten_array, dlme_split(';'), last, dlme_gsub(' original catalog number ', ''), dlme_prepend('Original Number: ')
to_field 'cho_medium', extract_json('.era'), flatten_array, lang('en')
to_field 'cho_periodo_period', extract_json('.geographic_culture'), flatten_array, translation_map('periodo_from_contributor')
to_field 'cho_spatial', extract_json('.geographic_country'), flatten_array, dlme_strip, dlme_transform(&:downcase), translation_map('spatial_from_contributor'), lang('en')
to_field 'cho_spatial', extract_json('.geographic_country'), flatten_array, dlme_strip, dlme_transform(&:downcase), translation_map('spatial_from_contributor'), translation_map('spatial_ar_from_en'), lang('ar-Arab')
to_field 'cho_spatial', extract_json('.geographic_municipality'), flatten_array, dlme_strip, dlme_transform(&:downcase), translation_map('spatial_from_contributor'), lang('en')
to_field 'cho_spatial', extract_json('.geographic_municipality'), flatten_array, dlme_strip, dlme_transform(&:downcase), translation_map('spatial_from_contributor'), translation_map('spatial_ar_from_en'), lang('ar-Arab')
to_field 'cho_temporal', extract_json('.geographic_culture'), flatten_array, dlme_strip, dlme_transform(&:downcase), translation_map('temporal_from_contributor'), lang('en')
to_field 'cho_temporal', extract_json('.geographic_culture'), flatten_array, dlme_strip, dlme_transform(&:downcase), translation_map('temporal_from_contributor'), translation_map('temporal_ar_from_en'), lang('ar-Arab')
to_field 'cho_type', extract_json('.format'), flatten_array, dlme_split(';'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_dc_rights' => literal('http://creativecommons.org/publicdomain/zero/1.0/'),
                                  'wr_id' => [extract_json('.callnumber'), flatten_array, dlme_prepend('https://collections.peabody.yale.edu/search/Record/'), dlme_gsub(' ', '-')],
                                  'wr_is_referenced_by' => [extract_json('.iiif_id'), flatten_array, dlme_prepend('https://manifests.collections.yale.edu')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_dc_rights' => literal('http://creativecommons.org/publicdomain/zero/1.0/'),
                                  'wr_id' => [extract_json('.image_id'), flatten_array, dlme_gsub('/full/full/', '/full/400,400/')],
                                  'wr_is_referenced_by' => [extract_json('.iiif_id'), flatten_array, dlme_prepend('https://manifests.collections.yale.edu')])
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
  'cho_aat_medium',
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
