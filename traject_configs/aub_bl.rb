# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/aub'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::AUB
extend Macros::Collection
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
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

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('aub-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('aub-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('aub-')

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', column('Reference'), strip
to_field 'cho_title', column('Title (In Original Language/Script)'), lang('ar-Arab')
to_field 'cho_title', column('Title (Transliterated)'), lang('ar-Latn')

# Cho Other
to_field 'cho_contributor', column('Editor(s) of the Original Material'), prepend('Editor: '), strip, lang('en')
to_field 'cho_contributor', column('Scribe(s) of the Original Material'), prepend('Scribe: '), strip, lang('en')
to_field 'cho_creator', column('Author(s) / Creators of the Original Material'), parse_csv, strip, lang('en')
to_field 'cho_date', column('Dates of Material (Gregorian Calendar)'), parse_csv, strip, lang('en')
to_field 'cho_date_range_hijri', column('Dates of Material (Gregorian Calendar)'), parse_csv, strip, parse_range, hijri_range
to_field 'cho_date_range_norm', column('Dates of Material (Gregorian Calendar)'), parse_csv, strip, parse_range
to_field 'cho_dc_rights', literal('Public domain'), lang('en')
to_field 'cho_description', column('Description'), strip, lang('en')
to_field 'cho_description', column('Condition of Original Material'), prepend('Condition: '), strip, lang('en')
to_field 'cho_edm_type', literal('Manuscripts'), translation_map('edm_type_from_has_type'), lang('en')
to_field 'cho_edm_type', literal('Manuscripts'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', column('Number and Type of Original Material'), strip, lang('en')
to_field 'cho_extent', column('Size and Dimensions of Original Material'), strip, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('Original Reference'), parse_csv, strip
to_field 'cho_language', column('Languages of Material'), lang('en')
to_field 'cho_language', column('Languages of Material'), translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_publisher', column('Publisher(s) of the Original Material'), parse_csv, strip, lang('en')
to_field 'cho_provenance', column('Custodial History'), parse_csv, strip, prepend('Custodial history: '), lang('en')
to_field 'cho_spatial', column('Country of Origin'), parse_csv, split('|'), strip, lang('en')
to_field 'cho_subject', column('Other Related Subjects'), parse_csv, split('|'), strip,  lang('en')
to_field 'cho_subject', column('Related Subjects'), parse_csv, split('|'), strip,  lang('en')
to_field 'cho_type', column('Content Type'), parse_csv, strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('File Reference'), gsub('/', '-'), strip, prepend('https://eap.bl.uk/archive-file/')],
    'wr_is_referenced_by' => [column('File Reference'), gsub('/', '-'), strip, prepend("https://eap.bl.uk/archive-file/"), append('/manifest')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('File Reference'), gsub('/', '_'), strip, prepend('https://images.eap.bl.uk/EAP1423/'), append('/11.jp2/full/!600,300/0/default.jpg')],
    'wr_is_referenced_by' => [column('File Reference'), gsub('/', '-'), strip, prepend("https://eap.bl.uk/archive-file/"), append('/manifest')]
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
each_record add_cho_type_facet
