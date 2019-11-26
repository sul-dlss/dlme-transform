# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/met'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::Met
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Note: Met JSON uses blanks ("") instead of nulls.

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# CHO Required
to_field 'id', extract_json('.objectID'), lambda { |_record, accumulator, context|
  accumulator.map! { |bare_id| identifier_with_prefix(context, bare_id.to_s) }
}
to_field 'cho_title', extract_json('.title'), lang('en')

# CHO Other
to_field 'cho_creator', generate_creator, lang('en')
to_field 'cho_coverage', extract_json('.culture'), transform(&:presence), lang('en')
to_field 'cho_coverage', extract_json('.dynasty'), transform(&:presence), lang('en')
to_field 'cho_coverage', extract_json('.excavation'), transform(&:presence), lang('en')
to_field 'cho_date', generate_object_date, transform(&:presence), lang('en')
to_field 'cho_date', extract_json('.objectDate'), transform(&:presence), lang('en')
to_field 'cho_date_range_hijri', met_date_range, hijri_range
to_field 'cho_date_range_norm', met_date_range
to_field 'cho_dc_rights', public_domain, lang('en')
to_field 'cho_dc_rights', extract_json('.rightsAndReproduction'), transform(&:presence), lang('en')
to_field 'cho_edm_type', literal('Image'), lang('en')
to_field 'cho_edm_type', literal('Image'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.dimensions'), lang('en')
to_field 'cho_format', extract_json('.objectName'), lang('en')
to_field 'cho_has_type', literal('Cultural Artifact'), lang('en')
to_field 'cho_has_type', literal('Cultural Artifact'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.accessionNumber')
to_field 'cho_medium', extract_json('.medium'), lang('en')
to_field 'cho_provenance', extract_json('.creditLine'), lang('en')
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
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
