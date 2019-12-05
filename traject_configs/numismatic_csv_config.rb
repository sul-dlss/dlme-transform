# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/numismatic_csv'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::NumismaticCsv
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

to_field 'agg_data_provider_collection', collection

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# CHO Required
to_field 'id', normalize_prefixed_id('RecordId')
to_field 'cho_title', column('Title'), strip, lang('en')

# CHO Other
to_field 'cho_contributor', column('Authority'), split('|'), strip, lang('en')
to_field 'cho_coverage', column('Findspot'), strip, lang('en')
to_field 'cho_creator', column('Mint'), strip, lang('en')
to_field 'cho_date', column('Era'), strip, lang('en')
to_field 'cho_date', column('Year'), gsub('|', ' - '), strip, lang('en')
to_field 'cho_date_range_norm', column('Year'), gsub('|', ' - '), parse_range
to_field 'cho_date_range_hijri', column('Year'), gsub('|', ' - '), parse_range, hijri_range
to_field 'cho_description', column('Denomination'), strip, lang('en')
to_field 'cho_description', column('Manufacture'), strip, lang('en')
to_field 'cho_description', column('Obverse Legend'), strip, lang('en')
to_field 'cho_description', column('Obverse Type'), strip, lang('en')
to_field 'cho_description', column('Reverse Legend'), strip
to_field 'cho_description', column('Reverse Type'), strip, lang('en')
to_field 'cho_description', column('Weight'), strip, lang('en')
to_field 'cho_edm_type', literal('Image'), lang('en')
to_field 'cho_edm_type', literal('Image'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', column('Diameter'), strip, lang('en')
to_field 'cho_identifier', column('URI')
to_field 'cho_identifier', column('RecordId')
to_field 'cho_medium', column('Material'), strip, lang('en')
to_field 'cho_source', column('Reference'), strip, lang('en')
to_field 'cho_spatial', column('Region'), strip, lang('en')
to_field 'cho_temporal', column('Dynasty'), strip, lang('en')
to_field 'cho_type', column('Object Type'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('URI')],
                                  'wr_is_referenced_by' => [column('URI'), gsub(/collection/, 'search/manifest')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('Thumbnail_obv')])
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
