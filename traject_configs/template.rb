# frozen_string_literal: true

require 'traject_plus'
require 'macros/csv'
require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'

extend Macros::Csv
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'allow_duplicate_values', false
  provide 'allow_nil_values', false
  provide 'allow_empty_fields', false
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# File path
to_field 'dlme_source_file', path_to_file

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection_id' # Arabic value
to_field 'agg_data_provider_collection' # English value
to_field 'agg_data_provider_collection'

# Cho Required
to_field 'id'
to_field 'cho_title'

# Cho Other
to_field 'cho_alternative'
to_field 'cho_contributor'
to_field 'cho_coverage'
to_field 'cho_creator'
to_field 'cho_date'
to_field 'cho_date_range_norm'
to_field 'cho_date_range_hijri'
to_field 'cho_dc_rights'
to_field 'cho_description'
to_field 'cho_edm_type' # Arabic value
to_field 'cho_edm_type' # English value
to_field 'cho_extent'
to_field 'cho_format'
to_field 'cho_has_part'
to_field 'cho_has_type' # Arabic value
to_field 'cho_has_type' # English value
to_field 'cho_identifier'
to_field 'cho_is_part_of'
to_field 'cho_language' # Arabic value
to_field 'cho_language' # English value
to_field 'cho_medium'
to_field 'cho_publisher'
to_field 'cho_provenance'
to_field 'cho_relation'
to_field 'cho_source'
to_field 'cho_spatial'
to_field 'cho_subject'
to_field 'cho_temporal'
to_field 'cho_type'
to_field 'cho_type_facet' # Arabic value, broader category
to_field 'cho_type_facet' # Arabic value, combined => Broader:Narrower
to_field 'cho_type_facet' # English value, broader category
to_field 'cho_type_facet' # English value, combined => Broader:Narrower

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [],
    'wr_edm_rights' => [],
    'wr_format' => [],
    'wr_id' => [],
    'wr_is_referenced_by' => []
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [],
    'wr_edm_rights' => [],
    'wr_format' => [],
    'wr_has_service' => [],
    'wr_id' => [],
    'wr_is_referenced_by' => []
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
# This may be used as an alternative to building 'cho_type_facet' directly,
# Don't use both.
each_record add_cho_type_facet
