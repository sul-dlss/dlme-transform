# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', literal('cluster'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('cluster'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('cluster')

# Cho Required
to_field 'id', column('url'), strip
to_field 'cho_title', column('title_en'), strip, lang('en')
to_field 'cho_title', column('title_ar'), strip, lang('ar-Arab')

# Cho Other
to_field 'cho_creator', column('creator_en'), strip, lang('en')
to_field 'cho_creator', column('creator_ar'), strip, lang('ar-Arab')
to_field 'cho_contributor', column('contributor_en'), strip, lang('en')
to_field 'cho_contributor', column('contributor_ar'), strip, lang('ar-Arab')
to_field 'cho_date', column('date'), strip, lang('en')
to_field 'cho_date_range_norm', column('date'), strip, parse_range
to_field 'cho_date_range_hijri', column('date'), strip, parse_range, hijri_range
to_field 'cho_description', column('description_en'), strip, lang('en')
to_field 'cho_description', column('description_ar'), strip, lang('en')
to_field 'cho_edm_type', literal('Dataset'), lang('en')
to_field 'cho_edm_type', literal('Dataset'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Geospatial'), lang('en')
to_field 'cho_has_type', literal('Geospatial'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', literal('Arabic'), lang('en')
to_field 'cho_language', literal('English'), lang('en')
to_field 'cho_language', literal('Arabic'), translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', literal('English'), translation_map('lang_ar_from_en'), lang('ar-Arab')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('url'), strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('thumbnail_image'), strip]
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
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
