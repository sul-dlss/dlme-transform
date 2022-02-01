# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/lausanne'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/penn'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::Lausanne
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Penn
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
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

to_field 'dlme_collection', literal('lausanne-ias'), translation_map('dlme_collection_from_provider_id'), lang('en')
to_field 'dlme_collection', literal('lausanne-ias'), translation_map('dlme_collection_from_provider_id'), translation_map('dlme_collection_ar_from_en'), lang('ar-Arab')
to_field 'dlme_collection_id', literal('lausanne-ias')

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', normalize_prefixed_id('id')
to_field 'cho_title', json_title_or('name', 'expanded_name'), lang('fr')

# CHO Other
to_field 'cho_date', lausanne_date_string, lang('en')
to_field 'cho_date_range_norm', csv_or_json_date_range('from', 'to')
to_field 'cho_date_range_hijri', csv_or_json_date_range('from', 'to'), hijri_range
to_field 'cho_description', column('expanded_name'), lang('fr')
to_field 'cho_description', column('location'), gsub('POINT(', ''), gsub(')', ''), lang('fr')
to_field 'cho_description', literal('Site: Tiresias'), lang('en')
to_field 'cho_description', column('precision'), prepend('Precision: '), lang('en')
to_field 'cho_edm_type', column('document_type_id'), translation_map('has_type_from_lausanne'), normalize_edm_type, lang('en')
to_field 'cho_edm_type', column('document_type_id'), translation_map('has_type_from_lausanne'), normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', column('width'), prepend('Width: '), lang('en')
to_field 'cho_extent', column('height'), prepend('Height: '), lang('en')
to_field 'cho_format', column('format'), lang('en')
to_field 'cho_has_type', column('document_type_id'), translation_map('has_type_from_lausanne'), lang('en')
to_field 'cho_has_type', column('document_type_id'), translation_map('has_type_from_lausanne'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_medium', column('material'), lang('fr')
to_field 'cho_source', column('literature'), lang('fr')
to_field 'cho_spatial', column('locatlity'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'agg_edm_rights' => [literal('InC: http://https://rightsstatements.org/page/InC/1.0')],
                                  'wr_dc_rights' => [literal('Paul Collart © ASA-UNIL'), lang('en')],
                                  'wr_id' => [column('id'), prepend('https://tiresias.unil.ch/card/')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'agg_edm_rights' => [literal('InC: http://https://rightsstatements.org/page/InC/1.0')],
                                  'wr_dc_rights' => [literal('Paul Collart © ASA-UNIL'), lang('en')],
                                  'wr_id' => [column('id'), prepend('https://tiresias.unil.ch/api/image/'), append('/300')])
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
  'dlme_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
