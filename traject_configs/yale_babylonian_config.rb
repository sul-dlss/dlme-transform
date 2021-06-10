# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::NormalizeType
extend Macros::PathToFile
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

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', column('id')
to_field 'cho_title', column('title'), lang('en')

# CHO Other
to_field 'cho_aat_material', column('era'), split(';'), split(':'), split('/'), strip, transform(&:downcase), translation_map('getty_aat_materials'), lang('en')
to_field 'cho_aat_material', column('era'), split(':'), strip, transform(&:downcase), translation_map('getty_aat_materials'), translation_map('getty_aat_materials_to_ar'), lang('ar-Arab')
to_field 'cho_description', column('type'), lang('en')
to_field 'cho_edm_type', literal('Object'), lang('en')
to_field 'cho_edm_type', literal('Object'), lang('ar-Arab')
to_field 'cho_format', column('format'), lang('en')
to_field 'cho_has_type', column('format'), split(';'), strip, translation_map('object_has_types'), lang('en')
to_field 'cho_has_type', column('format'), split(';'), strip, translation_map('object_has_types'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', column('callnumber'), prepend('Catalog Number: ')
to_field 'cho_identifier', column('type'), split(';'), last, gsub(' original catalog number ', ''), prepend('Original Number: ')
to_field 'cho_medium', column('era'), lang('en')
to_field 'cho_periodo_period', column('geographic_culture'), translation_map('periodo')
to_field 'cho_spatial', column('geographic_country'), lang('en')
to_field 'cho_spatial', column('geographic_municipality'), lang('en')
to_field 'cho_spatial_norm', column('geographic_country'), translation_map('spatial'), lang('en')
to_field 'cho_spatial_norm', column('geographic_municipality'), translation_map('spatial_to_ar'), lang('en')
to_field 'cho_temporal', column('geographic_culture'), lang('en')
to_field 'cho_temporal_norm', column('geographic_culture'), translation_map('temporal'), lang('en')
to_field 'cho_temporal_norm', column('geographic_culture'), translation_map('temporal'), translation_map('temporal_to_ar'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('callnumber'), prepend('https://collections.peabody.yale.edu/search/Record/'), gsub(' ', '-')],
                                  'wr_is_referenced_by' => [column('iiif_id'), prepend('https://manifests.collections.yale.edu')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('image_id'), gsub('/full/full/', '/full/400,400/')],
                                  'wr_is_referenced_by' => [column('iiif_id'), prepend('https://manifests.collections.yale.edu')])
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
  'cho_aat_medium',
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
