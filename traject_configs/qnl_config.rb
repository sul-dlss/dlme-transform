# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/qnl'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::Timestamp
extend Macros::Version
extend Macros::QNL
extend TrajectPlus::Macros

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# CHO Required
to_field 'id', extract_qnl_identifier, strip
to_field 'cho_title', extract_qnl('mods:titleInfo/mods:title')

# CHO Other
to_field 'cho_coverage', extract_qnl('mods:subject/mods:geographic'), strip
to_field 'cho_creator', extract_qnl('mods:name/mods:namePart'), strip
to_field 'cho_date', extract_qnl('mods:originInfo/mods:dateIssued'), strip
to_field 'cho_date_range_norm', extract_qnl('mods:originInfo/mods:dateIssued'), strip, gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', extract_qnl('mods:originInfo/mods:dateIssued'),
         strip, gsub('/', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', literal('Open Government Licence')
to_field 'cho_description', extract_qnl('mods:physicalDescription/mods:extent'), strip
to_field 'cho_edm_type', extract_qnl('mods:typeOfResource'),
         strip, transform(&:downcase), translation_map('not_found', 'types')
to_field 'cho_extent', extract_qnl('mods:physicalDescription/mods:extent[1]'), strip
to_field 'cho_identifier', extract_qnl('mods:recordInfo/mods:recordIdentifier')
to_field 'cho_language', extract_qnl('mods:language/mods/languageTerm'),
         strip, transform(&:downcase), translation_map('not_found', 'languages', 'marc_languages')
to_field 'cho_subject', extract_qnl('mods:subject/mods:topic'), strip

# Agg
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_qnl('mods:location/mods:url'), strip]
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
