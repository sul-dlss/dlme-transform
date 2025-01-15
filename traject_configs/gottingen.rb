# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
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
require 'macros/transformation'
require 'macros/title_extraction'
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

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('gottingen-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('gottingen-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('gottingen-')

# Cho Required
to_field 'id', extract_json('.id'),
         flatten_array,
         dlme_strip,
         dlme_gsub('https://sammlungen.uni-goettingen.de/api/v1/records/', ''),
         dlme_gsub('/manifest/', '')
to_field 'cho_title', extract_json('.inventarnummer'), flatten_array, dlme_strip, lang('en')

# Cho Other
to_field 'cho_date', extract_json('.herstellung:-datierung'), flatten_array, dlme_strip, lang('de')
to_field 'cho_date_range_norm', extract_json('.datierung-kodiert'), flatten_array, dlme_strip, dlme_gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', extract_json('.datierung-kodiert'), flatten_array, dlme_strip, dlme_gsub('/', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('image-rights'), flatten_array, lang('de')
to_field 'cho_description', extract_json('.beschreibung'), flatten_array, dlme_strip, dlme_prepend('Iconclass: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_edm_type', literal('Object'), lang('en')
to_field 'cho_edm_type', literal('Object'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.maße--umfang'), flatten_array, dlme_strip, lang('de')
to_field 'cho_has_type', extract_json('.object-genre'), flatten_array, normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.object-genre'), flatten_array, normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.inventarnummer'), flatten_array, dlme_strip
to_field 'cho_is_part_of', extract_json('.sammlung'), flatten_array, dlme_strip, lang('de')
to_field 'cho_relation', extract_json('.verknüpfte-objekte'), flatten_array, dlme_strip, lang('de')
to_field 'cho_spatial', extract_json('.koordinaten-des-standorts'), flatten_array, dlme_strip, lang('en')
to_field 'cho_spatial', extract_json('.gebrauch:-ort'), flatten_array, dlme_strip, lang('de')
to_field 'cho_spatial', extract_json('.name-des-standorts'), flatten_array, dlme_strip, lang('de')
to_field 'cho_spatial', extract_json('.herstellung:-ort'), flatten_array, dlme_strip, lang('de')
to_field 'cho_subject', extract_json('.iconclass'), flatten_array, dlme_strip, lang('de')
to_field 'cho_subject', extract_json('.keywords'), flatten_array, dlme_strip, lang('de')
to_field 'cho_temporal', extract_json('.entstehung:-datierung'), flatten_array, dlme_strip, lang('de')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.id'), dlme_gsub('https://sammlungen.uni-goettingen.de/api/v1/records/', 'https://sammlungen.uni-goettingen.de/objekt/'), dlme_gsub('manifest/', ''), flatten_array, dlme_strip],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.thumbnail'), flatten_array, at_index(0), dlme_strip],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip]
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
  'dlme_collection',
  'agg_data_provider_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
