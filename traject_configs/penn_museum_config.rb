# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_type'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Csv
extend Macros::DLME
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::NormalizeType
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

# CHO Required
to_field 'id', normalize_prefixed_id('emuIRN')
to_field 'cho_title', column('object_name'), split('|')

# CHO Other
to_field 'cho_coverage', column('culture'), split('|')
to_field 'cho_creator', column('creator')
to_field 'agg_data_provider', column('curatorial_section'), append(' Section, Penn Museum')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'cho_date', column('date_made')
to_field 'cho_date', column('date_made_early')
to_field 'cho_date', column('date_made_late')
to_field 'cho_date_range_norm', penn_museum_date_range
to_field 'cho_date_range_hijri', penn_museum_date_range, hijri_range
to_field 'cho_description', column('description')
to_field 'cho_description', column('technique'), split('|')
to_field 'cho_edm_type', literal('Image')
to_field 'cho_extent', column('measurement_height')
to_field 'cho_extent', column('measurement_length')
to_field 'cho_extent', column('measurement_outside_diameter')
to_field 'cho_extent', column('measurement_tickness')
to_field 'cho_extent', column('measurement_unit')
to_field 'cho_extent', column('measurement_width')
to_field 'cho_identifier', column('emuIRN')
to_field 'cho_medium', column('material'), split('|')
to_field 'cho_provenance', column('accession_credit_line')
to_field 'cho_source', column('object_number')
to_field 'cho_source', column('other_numbers'), split('|')
to_field 'cho_spatial', column('provenience'), split('|')
to_field 'cho_subject', column('iconography')
to_field 'cho_temporal', column('period'), split('|')
to_field 'cho_type', column('object_name')

# Agg
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('url')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('thumbnail'), gsub('collections/assets/1600', 'collections/assets/300')])
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
