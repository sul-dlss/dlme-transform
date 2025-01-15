# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/transformation'
require 'macros/version'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::FieldExtraction
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::StringHelper
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

to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('brooklyn-')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('brooklyn-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('brooklyn-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')

# Cho Required
to_field 'id', extract_json('.id'), transform(&:to_s), dlme_strip, dlme_prepend('brooklyn-')
to_field 'cho_title', extract_json('.title'), dlme_default('Untitled'), dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')

# Cho Other
to_field 'cho_creator', extract_json('.artists.name'), lang('en')
to_field 'cho_date', extract_json('.object_date'), dlme_strip, lang('en')
to_field 'cho_date_range_norm', csv_or_json_date_range('object_date_begin', 'object_date_end'), transform(&:to_s), dlme_strip, parse_range
to_field 'cho_date_range_hijri', csv_or_json_date_range('object_date_begin', 'object_date_end'), transform(&:to_s), dlme_strip, parse_range, hijri_range
to_field 'cho_description', extract_json('.description'), dlme_strip, lang('en')
to_field 'cho_description', extract_json('.inscribed'), dlme_strip, dlme_prepend('Inscribed: '), lang('en')
to_field 'cho_description', extract_json('.signed'), dlme_strip, dlme_prepend('Signed: '), lang('en')
to_field 'cho_edm_type', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, lang('en')
to_field 'cho_edm_type', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.dimensions'), lang('en')
to_field 'cho_has_type', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), odd_only, lang('en')
to_field 'cho_has_type', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), odd_only, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.accession_number'), dlme_strip, dlme_prepend('Accession Number: ')
to_field 'cho_is_part_of', extract_json('.collections.name'), dlme_strip, lang('en')
to_field 'cho_medium', extract_json('.medium'), lang('en')
to_field 'cho_provenance', extract_json('.credit_line'), lang('en')
to_field 'cho_relation', extract_json('.related_items.object_id'), dlme_prepend('https://dlmenetwork.org/library/catalog/brooklyn-'), lang('en')
to_field 'cho_spatial', extract_json('.geographical_locations.name'), dlme_strip, lang('en')
to_field 'cho_temporal', extract_json('.period'), dlme_strip, lang('en')
to_field 'cho_type', extract_json('.classification'), lang('en')
to_field 'cho_type_facet', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), lang('en')
to_field 'cho_type_facet', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, lang('en')
to_field 'cho_type_facet', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), translation_map('type_hierarchy_ar_from_en'), lang('ar-Arab')
to_field 'cho_type_facet', extract_json('.classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, translation_map('edm_type_ar_from_en'), lang('ar-Arab')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.id'), transform(&:to_s), dlme_strip, dlme_prepend('https://www.brooklynmuseum.org/opencollection/objects/')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.preview'), dlme_strip, dlme_prepend('https://d1lfxha3ugu3d4.cloudfront.net/images/opencollection/objects/size2/')]
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
each_record add_cho_type_facet
