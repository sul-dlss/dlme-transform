# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
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
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'allow_duplicate_values', false
  provide 'allow_nil_values', false
  provide 'allow_empty_fields', false
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', literal('csic'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('csic'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('csic')

# CHO Required
to_field 'id', column('id')
to_field 'cho_title', column('245_a'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_title', column('245_c'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'es')

# CHO Other
to_field 'cho_alternative', column('740_a'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_contributor', column('700_a'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_creator', column('100_a'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_creator', column('100_d'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_date', column('260_c'), parse_csv, strip, lang('und-Latn')
to_field 'cho_description', column('500_a'), parse_csv, strip, prepend('Annotations: '), lang('es')
to_field 'cho_description', column('520_a'), parse_csv, strip, prepend('Contents: '), lang('es')
to_field 'cho_description', column('563_a'), parse_csv, strip, prepend('Binding: '), lang('es')
to_field 'cho_description', column('546_b'), parse_csv, strip, prepend('Script: '), lang('es')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', column('300_a'), parse_csv, strip, lang('es')
to_field 'cho_extent', column('300_c'), parse_csv, strip, lang('es')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', column('546_a'), normalize_language, lang('en')
to_field 'cho_language', column('546_a'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', column('541_a'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('600_a'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('600_t'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('600_x'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('600_v'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('630_a'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('630_x'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('650_a'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('650_x'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('650_z'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('651_a'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('651_x'), parse_csv, strip, lang('es')
to_field 'cho_subject', column('651_y'), parse_csv, strip, lang('es')
to_field 'cho_type', column('245_hh'), parse_csv, strip, lang('es')

# Agg Required
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [column('035_a'), parse_csv, strip, prepend('http://aleph.csic.es/imagenes/mad01/0006_PMSC/thumb/'), append('.jpg')])
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

# Agg Additional
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [column('856_u')])
end

# NOTE:  add the below to collection specific config
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
