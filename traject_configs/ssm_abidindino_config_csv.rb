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
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', literal('ssm-abidindino'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('ssm-abidindino'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('ssm-abidindino')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', column('id'), gsub('oai:cdm21044.contentdm.oclc.org:', ''), gsub('/', '-')
to_field 'cho_title', column('title'), parse_csv, lang('tr-Latn')

# Cho Other
to_field 'cho_contributor', column('contributor'), parse_csv, split('. '), gsub('.', ''), lang('tr-Latn')
to_field 'cho_coverage', column('coverage'), parse_csv, lang('tr-Latn')
to_field 'cho_creator', column('creator'), parse_csv, lang('tr-Latn')
to_field 'cho_date', column('date'), parse_csv, lang('tr-Latn')
to_field 'cho_date_range_norm', column('date'), parse_range
to_field 'cho_date_range_hijri', column('date'), parse_range, hijri_range
to_field 'cho_dc_rights', column('rights'), parse_csv, lang('tr-Latn')
to_field 'cho_description', column('description'), parse_csv, lang('tr-Latn')
to_field 'cho_edm_type', column('type'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', column('type'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', column('format'), parse_csv, lang('tr-Latn')
to_field 'cho_has_type', column('type'), normalize_has_type, lang('en')
to_field 'cho_has_type', column('type'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('identifier'), parse_csv
to_field 'cho_language', column('language'), normalize_language, lang('en')
to_field 'cho_publisher', column('publisher'), parse_csv, lang('tr-Latn')
to_field 'cho_subject', column('subject'), parse_csv, lang('tr-Latn')
to_field 'cho_type', column('type'), parse_csv, lang('tr-Latn')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'agg_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_format' => [column('format'), parse_csv],
    'wr_id' => [column('identifier'), parse_csv, at_index(-1)],
    'wr_is_referenced_by' => [column('id'), gsub('oai:cdm21044.contentdm.oclc.org:', ''), prepend('https://cdm21044.contentdm.oclc.org/iiif/info/'), append('/manifest.json')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_format' => [column('format'), parse_csv],
    'wr_id' => [column('id'), parse_csv, gsub('oai:cdm21044.contentdm.oclc.org:', ''), prepend('https://cdm21044.contentdm.oclc.org/digital/iiif/'), append('/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [column('id'), gsub('oai:cdm21044.contentdm.oclc.org:', ''), prepend('https://cdm21044.contentdm.oclc.org/iiif/info/'), append('/manifest.json')]
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
  'cho_type',
  'agg_data_provider_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
