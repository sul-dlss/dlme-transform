# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'dlme_json_resource_writer'
require 'macros/content_dm'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_type'
require 'macros/oai'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::ContentDm
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::OAI
extend Macros::NormalizeType
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# CHO Required
to_field 'id', extract_oai_identifier, strip
to_field 'cho_title', extract_oai('dc:title'), strip, lang('en')

# CHO Other
to_field 'cho_coverage', extract_oai('dc:coverage'), strip, lang('en')
to_field 'cho_creator', extract_oai('dc:creator'),
         strip, split('.'), lang('en')
to_field 'cho_date', extract_oai('dc:date'), strip, lang('en')
to_field 'cho_date_range_hijri', extract_oai('dc:date'), strip, auc_date_range, hijri_range
to_field 'cho_date_range_norm', extract_oai('dc:date'), strip, auc_date_range
to_field 'cho_description', extract_oai('dc:description'), strip, lang('en')
to_field 'cho_dc_rights', extract_oai('dc:rights'), strip, lang('en')
to_field 'cho_edm_type', extract_oai('dc:type'),
         split(';'), strip, transform(&:downcase), normalize_type, lang('en')
to_field 'cho_edm_type', extract_oai('dc:type'),
         split(';'), strip, transform(&:downcase), normalize_type, translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_format', extract_oai('dc:format'), strip, lang('en')
to_field 'cho_has_type', literal('Drawing'), lang('en')
to_field 'cho_has_type', literal('Drawing'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
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
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_cdm_preview]
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
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
