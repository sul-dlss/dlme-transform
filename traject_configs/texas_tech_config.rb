# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/oai'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::OAI
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', literal('texas-tech'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('texas-tech'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('texas-tech')

# Cho Required
to_field 'id', extract_oai_identifier, strip
to_field 'cho_title', extract_oai('dc:title'), strip, lang('en')

# Cho Other
to_field 'cho_creator', extract_oai('dc:creator'),
         strip, split('.'), lang('en')
to_field 'cho_date', extract_oai('dc:date'), last, strip, lang('en')
to_field 'cho_date_range_hijri', extract_oai('dc:date'), strip, parse_range, hijri_range
to_field 'cho_date_range_norm', extract_oai('dc:date'), strip, parse_range
to_field 'cho_dc_rights', extract_oai('dc:rights'), strip, lang('en')
to_field 'cho_description', extract_oai('dc:description'), strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_oai('dc:format'), strip, lang('en')
to_field 'cho_has_type', literal('Other Texts'), lang('en')
to_field 'cho_has_type', literal('Other Texts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_oai('dc:language'), normalize_language, lang('en')
to_field 'cho_language', extract_oai('dc:language'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_publisher', extract_oai('dc:publisher'), strip, lang('en')
to_field 'cho_subject', extract_oai('dc:subject'), strip, lang('en')
to_field 'cho_type', extract_oai('dc:type'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_oai('dc:identifier[last()]'), strip]
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
  'agg_data_provider_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
