# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_type'
require 'macros/penn'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::NormalizeType
extend Macros::Penn
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', literal('penn-near-east'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('penn-near-east'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('penn-near-east')

# CHO Required
to_field 'id', normalize_prefixed_id('emuIRN')
to_field 'cho_title', column('object_name'), split('|'), lang('en')

# CHO Other
to_field 'cho_coverage', column('culture'), split('|'), lang('en')
to_field 'cho_creator', column('creator'), lang('en')
to_field 'cho_date', column('date_made'), lang('en')
to_field 'cho_date', column('date_made_early'), lang('en')
to_field 'cho_date', column('date_made_late'), lang('en')
to_field 'cho_date_range_norm', csv_or_json_date_range('date_made_early', 'date_made_late')
to_field 'cho_date_range_hijri', csv_or_json_date_range('date_made_early', 'date_made_late'), hijri_range
to_field 'cho_description', column('description'), lang('en')
to_field 'cho_description', column('technique'), split('|'), lang('en')
to_field 'cho_edm_type', column('object_name'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', column('object_name'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', column('measurement_height'), lang('en')
to_field 'cho_extent', column('measurement_length'), lang('en')
to_field 'cho_extent', column('measurement_outside_diameter'), lang('en')
to_field 'cho_extent', column('measurement_tickness'), lang('en')
to_field 'cho_extent', column('measurement_unit'), lang('en')
to_field 'cho_extent', column('measurement_width'), lang('en')
to_field 'cho_has_type', column('object_name'), normalize_has_type, lang('en')
to_field 'cho_has_type', column('object_name'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('emuIRN')
to_field 'cho_medium', column('material'), split('|'), lang('en')
to_field 'cho_provenance', column('accession_credit_line'), lang('en')
to_field 'cho_source', column('object_number'), lang('en')
to_field 'cho_source', column('other_numbers'), split('|'), lang('en')
to_field 'cho_spatial', column('provenience'), split('|'), lang('en')
to_field 'cho_subject', column('iconography'), lang('en')
to_field 'cho_temporal', column('period'), split('|'), lang('en')
to_field 'cho_type', column('object_name'), split('|'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('url')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('thumbnail'), gsub('collections/assets/1600', 'collections/assets/300')])
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
