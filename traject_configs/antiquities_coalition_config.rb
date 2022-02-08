# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

to_field 'agg_data_provider_collection', literal('antiquities'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('antiquities'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('antiquities')

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Cho Required
to_field 'id', extract_json('.url'), strip
to_field 'cho_title', extract_json('.title'), strip, lang('en')

# Cho Other
to_field 'cho_date', extract_json('.date'), strip, lang('en')
to_field 'cho_date_range_norm', extract_json('.date'), strip, parse_range
to_field 'cho_date_range_hijri', extract_json('.date'), strip, parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('.rights'), strip, lang('en')
to_field 'cho_description', extract_json('.description'), strip, lang('en')
to_field 'cho_edm_type', literal('Dataset'), lang('en')
to_field 'cho_edm_type', literal('Dataset'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', literal('English'), lang('en')
to_field 'cho_language', literal('Arabic'), translation_map('lang_ar_from_en'), lang('ar-Arab')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.url'), strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.thumbnail'), strip]
  )
end
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

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
