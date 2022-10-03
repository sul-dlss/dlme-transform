# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/brooklyn'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/version'

extend Macros::Brooklyn
extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::FieldExtraction
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# File path
to_field 'dlme_source_file', path_to_file

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection_id', brooklyn_collection_id
to_field 'agg_data_provider_collection', brooklyn_collection_id, translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', brooklyn_collection_id, translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')

# Cho Required
to_field 'id', extract_json_from_context('id'), transform(&:to_s), strip, prepend('brooklyn-')
to_field 'cho_title', extract_json_from_context('title'), strip, arabic_script_lang_or_default('und-Arab', 'en')

# Cho Other
to_field 'cho_creator', extract_json_list('artists', 'name'), lang('en')
to_field 'cho_date', extract_json_from_context('object_date'), strip, lang('en')
to_field 'cho_date_range_norm', csv_or_json_date_range('object_date_begin', 'object_date_end'), transform(&:to_s), strip, parse_range
to_field 'cho_date_range_hijri', csv_or_json_date_range('object_date_begin', 'object_date_end'), transform(&:to_s), strip, parse_range, hijri_range
to_field 'cho_dc_rights', brooklyn_rights, strip, lang('en')
to_field 'cho_description', extract_json_from_context('description'), strip, lang('en')
to_field 'cho_description', extract_json_from_context('inscribed'), strip, prepend('Inscribed: '), lang('en')
to_field 'cho_description', extract_json_from_context('signed'), strip, prepend('Signed: '), lang('en')
to_field 'cho_edm_type', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, lang('en')
to_field 'cho_edm_type', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json_from_context('dimensions'), lang('en')
to_field 'cho_has_type', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), odd_only, lang('en')
to_field 'cho_has_type', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), odd_only, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json_from_context('accession_number'), strip, prepend('Accession Number: ')
to_field 'cho_is_part_of', extract_json_list('collections', 'name'), strip, lang('en')
to_field 'cho_medium', extract_json_from_context('medium'), lang('en')
to_field 'cho_provenance', extract_json_from_context('credit_line'), lang('en')
to_field 'cho_relation', extract_json_list('related_items', 'name')
to_field 'cho_spatial', extract_json_list('geographical_locations', 'name'), strip, lang('en')
to_field 'cho_temporal', extract_json_from_context('period'), strip, lang('en')
to_field 'cho_type', extract_json_from_context('classification'), lang('en')
to_field 'cho_type_facet', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), lang('en')
to_field 'cho_type_facet', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, lang('en')
to_field 'cho_type_facet', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), translation_map('type_hierarchy_ar_from_en'), lang('ar-Arab')
to_field 'cho_type_facet', extract_json_from_context('classification'), transform(&:downcase), translation_map('type_hierarchy_from_contributor'), split(':'), even_only, translation_map('edm_type_ar_from_en'), lang('ar-Arab')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json_from_context('id'), transform(&:to_s), strip, prepend('https://www.brooklynmuseum.org/opencollection/objects/')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json_list('images', 'standard_size_url'), strip, prepend('http://')]
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
