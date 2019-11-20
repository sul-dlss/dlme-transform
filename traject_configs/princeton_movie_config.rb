# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

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

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Cho Required
to_field 'id', extract_json('.identifier'), strip
to_field 'cho_title', extract_json('.title'), strip

# Cho Other
to_field 'cho_contributor', extract_json('.director'), strip
to_field 'cho_contributor', extract_json('.rendered_actors'), strip
to_field 'cho_date', extract_json('.date_created'), strip
to_field 'cho_date_range_norm', extract_json('.date_created'), strip, parse_range
to_field 'cho_date_range_hijri', extract_json('.date_created'), strip, parse_range, hijri_range
to_field 'cho_dc_rights', literal('https://rbsc.princeton.edu/services/imaging-publication-services')
to_field 'cho_description', extract_json('.member_of_collections'), strip
to_field 'cho_edm_type', literal('Image')
to_field 'cho_extent', extract_json('.extent'), strip
to_field 'cho_identifier', extract_json('.local_identifier'), strip
to_field 'cho_language', extract_json('.language'), strip
to_field 'cho_type', extract_json('.resource_type')
to_field 'cho_type', extract_json('.genre')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.identifier'), strip]
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
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
