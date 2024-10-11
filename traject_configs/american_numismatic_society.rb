# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/timestamp'
require 'macros/transformation'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::Timestamp
extend Macros::Transformation
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'allow_duplicate_values', false
  provide 'allow_nil_values', false
  provide 'allow_empty_fields', false
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', literal('ans'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('ans'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('ans')

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', extract_json('.RecordId'), dlme_prepend('ans-')
to_field 'cho_title', extract_json('.Title'), flatten_array, dlme_strip, lang('en')

# CHO Other
to_field 'cho_contributor', extract_json('.Maker'), flatten_array, dlme_split('||'), dlme_strip, dlme_prepend('Maker: '), lang('en')
to_field 'cho_creator', extract_json('.Authority'), flatten_array, dlme_split('||'), dlme_strip, dlme_prepend('Authority: '), lang('en')
to_field 'cho_date', extract_json('.Ah'), flatten_array, transform(&:to_s), dlme_split('.'), first_only, dlme_strip, dlme_append(' AH'), lang('en')
to_field 'cho_date_range_norm', csv_or_json_date_range('From Date', 'To Date')
to_field 'cho_date_range_hijri', csv_or_json_date_range('From Date', 'To Date'), hijri_range
to_field 'cho_dc_rights', literal('Public Domain'), lang('en')
to_field 'cho_description', extract_json('.Axis'), flatten_array, transform(&:to_s), dlme_strip, dlme_prepend('Axis: '), lang('en')
to_field 'cho_description', extract_json('.Denomination'), flatten_array, dlme_strip, dlme_prepend('Denomination: '), lang('en')
to_field 'cho_description', extract_json('.Findspot'), flatten_array, dlme_strip, dlme_prepend('Findspot: '), lang('en')
to_field 'cho_description', extract_json('.Obverse Legend'), flatten_array, dlme_strip, dlme_prepend('Obverse legend: '), lang('en')
to_field 'cho_description', extract_json('.Obverse Type'), flatten_array, dlme_strip, dlme_prepend('Obverse type: '), lang('en')
to_field 'cho_description', extract_json('.Reverse Legend'), flatten_array, dlme_strip, dlme_prepend('Reverse legend: '), lang('en')
to_field 'cho_description', extract_json('.Reverse Type'), flatten_array, dlme_strip, dlme_prepend('Reverse type: '), lang('en')
to_field 'cho_edm_type', literal('Object'), lang('en')
to_field 'cho_edm_type', literal('Object'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.Diameter'), flatten_array, dlme_strip, dlme_prepend('Diameter: '), lang('en')
to_field 'cho_extent', extract_json('.Weight'), flatten_array, dlme_strip, dlme_prepend('Weight: '), lang('en')
to_field 'cho_has_type', literal('Coins'), lang('en')
to_field 'cho_has_type', literal('Coins'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.URI'), flatten_array
to_field 'cho_identifier', extract_json('.RecordId'), flatten_array
to_field 'cho_medium', extract_json('.Material'), flatten_array, dlme_strip, lang('en')
to_field 'cho_source', extract_json('.Reference'), flatten_array, dlme_strip, lang('en')
to_field 'cho_spatial', extract_json('.Mint'), flatten_array, dlme_split('||'), dlme_strip, dlme_prepend('Mint: '), lang('en')
to_field 'cho_spatial', extract_json('.Region'), flatten_array, dlme_split('||'), dlme_strip, dlme_prepend('Region: '), lang('en')
to_field 'cho_spatial', extract_json('.State'), flatten_array, dlme_split('||'), dlme_strip, dlme_prepend('State: '), lang('en')
to_field 'cho_temporal', extract_json('.Dynasty'), flatten_array, dlme_split('||'), dlme_strip, lang('en')
to_field 'cho_type', extract_json('.Object Type'), flatten_array, dlme_strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_edm_rights', literal('https://creativecommons.org/share-your-work/public-domain/cc0/')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.RecordId'), dlme_prepend('http://numismatics.org/collection/')],
                                  'wr_dc_rights' => [literal('Public Domain')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.Thumbnail_obv'), dlme_gsub('width175', 'width350')],
                                  'wr_dc_rights' => [literal('Public Domain')])
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
