# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/harvard'
require 'macros/post_process'

extend Macros::DateParsing
extend Macros::DLME
extend Macros::PostProcess
extend Macros::Harvard
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Cho Required
to_field 'id', extract_harvard_identifier, strip
to_field 'cho_title', extract_harvard('/*/dc:title'), strip, first_only

# Cho Other
to_field 'cho_alternative', extract_harvard('/*/dc:title[last()]'), strip
to_field 'cho_contributor', extract_harvard('/*/dc:contributor'), strip
to_field 'cho_coverage', extract_harvard('/*/dc:coverage'), strip
to_field 'cho_creator', extract_harvard('/*/dc:creator'), strip
to_field 'cho_date', extract_harvard('/*/dc:date'), strip
to_field 'cho_date_range_norm', extract_harvard('/*/dc:date'), strip, harvard_ihp_date_range
to_field 'cho_date_range_hijri', extract_harvard('/*/dc:date'), strip, harvard_ihp_date_range, hijri_range
to_field 'cho_description', extract_harvard('/*/dc:description'), strip
to_field 'cho_dc_rights', extract_harvard('/*/dc:rights'), strip
to_field 'cho_edm_type', extract_harvard('/*/dc:type[1]'),
         strip, transform(&:downcase), translation_map('not_found', 'types')
to_field 'cho_format', extract_harvard('/*/dc:format'), strip
to_field 'cho_language', extract_harvard('/*/dc:language'),
         split(' '), first_only, strip, transform(&:downcase), translation_map('not_found', 'iso_639-2')
to_field 'cho_publisher', extract_harvard('/*/dc:publisher'), strip
to_field 'cho_relation', extract_harvard('/*/dc:relation'), strip
to_field 'cho_subject', extract_harvard('/*/dc:subject'), strip

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_harvard('/*/dc:identifier[last()]'), strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_harvard_thumb]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')

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
