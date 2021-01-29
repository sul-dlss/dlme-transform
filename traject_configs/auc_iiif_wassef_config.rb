# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
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

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_json('.id'), strip, gsub('/manifest.json', ''), gsub('https://cdm15795.contentdm.oclc.org/iiif/info/', '')
to_field 'cho_title', extract_json('.title'), strip, lang('en')

# Cho Other
to_field 'cho_creator', extract_json('.architect'),
         strip, prepend('Architect: '), lang('en')
to_field 'cho_date', extract_json('.date-created'), strip, lang('en')
to_field 'cho_date_range_hijri', extract_json('.date-created'), strip, auc_date_range, hijri_range
to_field 'cho_date_range_norm', extract_json('.date-created'), strip, auc_date_range
to_field 'cho_dc_rights', extract_json('.license'), strip, lang('en')
to_field 'cho_edm_type', literal('Image'), lang('en')
to_field 'cho_edm_type', literal('Image'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.extent'), strip, lang('en')
to_field 'cho_has_type', literal('Architectural Drawing'), lang('en')
to_field 'cho_has_type', literal('Architectural Drawing'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.identifier'), strip
to_field 'cho_identifier', extract_json('.original-identifier'), strip
to_field 'cho_is_part_of', extract_json('.collection'), strip, lang('en')
to_field 'cho_spatial', extract_json('.location'), strip, lang('en')
to_field 'cho_subject', extract_json('.subject-lcsh'), strip, lang('en')
to_field 'cho_type', extract_json('.medium'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.access-rights'), strip],
    'wr_format' => [extract_json('.iiif_format'), strip],
    'wr_id' => [extract_json('.resource')],
    'wr_is_referenced_by' => [extract_json('.manifest'), strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.access-rights'), strip],
    'wr_format' => [extract_json('.iiif_format'), strip],
    'wr_id' => [extract_json('.resource'), strip, gsub('/full/full/0/default.jpg', '/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [extract_json('.manifest'), strip]
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
