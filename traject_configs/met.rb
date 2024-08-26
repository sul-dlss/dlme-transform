# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/met'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::Met
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
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

# NOTE: Met JSON uses blanks ("") instead of nulls.

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', literal('met'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('met'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('met')

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', extract_json('.objectID'), lambda { |_record, accumulator, context|
  accumulator.map! { |bare_id| identifier_with_prefix(context, bare_id.to_s) }
}
to_field 'cho_title', json_title_plus('title', 'dimensions'), squish, lang('en')

# CHO Other
to_field 'cho_coverage', extract_json('.culture'), transform(&:presence), lang('en')
to_field 'cho_coverage', extract_json('.dynasty'), transform(&:presence), lang('en')
to_field 'cho_coverage', extract_json('.excavation'), transform(&:presence), lang('en')
to_field 'cho_creator', generate_creator, lang('en')
to_field 'cho_date', generate_object_date, transform(&:presence), lang('en')
to_field 'cho_date', extract_json('.objectDate'), transform(&:presence), lang('en')
to_field 'cho_date_range_hijri', csv_or_json_date_range('objectBeginDate', 'objectEndDate'), hijri_range
to_field 'cho_date_range_norm', csv_or_json_date_range('objectBeginDate', 'objectEndDate')
to_field 'cho_dc_rights', public_domain, lang('en')
to_field 'cho_dc_rights', extract_json('.rightsAndReproduction'), transform(&:presence), lang('en')
to_field 'cho_edm_type', extract_json('.classification'), split('-'), last, normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.classification'), split('-'), last, normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.dimensions'), lang('en')
to_field 'cho_has_type', extract_json('.classification'), split('-'), last, normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.classification'), split('-'), last, normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.accessionNumber')
to_field 'cho_medium', extract_json('.medium'), lang('en')
to_field 'cho_spatial', extract_json('.city'), transform(&:presence), lang('en')
to_field 'cho_spatial', extract_json('.country'), transform(&:presence), lang('en')
to_field 'cho_spatial', extract_json('.county'), transform(&:presence), lang('en')
to_field 'cho_spatial', extract_json('.locale'), transform(&:presence), lang('en')
to_field 'cho_spatial', extract_json('.locus'), transform(&:presence), lang('en')
to_field 'cho_spatial', extract_json('.region'), transform(&:presence), lang('en')
to_field 'cho_spatial', extract_json('.river'), transform(&:presence), lang('en')
to_field 'cho_spatial', extract_json('.subregion'), transform(&:presence), lang('en')
to_field 'cho_temporal', extract_json('reign'), transform(&:presence), lang('en')
to_field 'cho_temporal', extract_json('.period'), transform(&:presence), lang('en')
to_field 'cho_type', extract_json('.classification'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.objectURL'), transform(&:presence),
                                              ->(_record, inner_accumulator) { inner_accumulator.compact! }])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.primaryImageSmall'), transform(&:presence),
                                              ->(_record, inner_accumulator) { inner_accumulator.compact! }])
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
