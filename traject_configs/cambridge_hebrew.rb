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

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('bnf-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('bnf-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('bnf-')

# Cho Required
to_field 'id', column('id'), gsub('https://cudl.lib.cam.ac.uk/iiif/', ''), strip
to_field 'cho_title', column('title'), parse_csv, strip, hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', column('uniform-title'), parse_csv, strip, hebrew_script_lang_or_default('ar-Arab', 'en')

# Cho Other
to_field 'cho_alternative', column('alternative-titles'), parse_csv, strip, lang('en')
to_field 'cho_contributor', column('scribes'), parse_csv, strip, prepend('Scribes: '), lang('en')
to_field 'cho_contributor', column('associated-names'), parse_csv, strip, prepend('Scribes: '), lang('en')
to_field 'cho_creator', column('authors'), parse_csv, strip, lang('en')
to_field 'cho_date', column('date-of-creation'), parse_csv, strip, lang('en')
to_field 'cho_date_range_norm', column('date-of-creation'), parse_csv, strip, parse_range
to_field 'cho_date_range_hijri', column('date-of-creation'), parse_csv, strip, parse_range, hijri_range
to_field 'cho_description', column('abstract'), parse_csv, strip, prepend('Abstract: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('additions'), parse_csv, strip, prepend('Abstract: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('binding'), parse_csv, strip, prepend('Binding: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('condition'), parse_csv, strip, prepend('Condition: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('decoration'), parse_csv, strip, prepend('Decoration: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('description'), parse_csv, split('/'), strip, hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('foliation'), parse_csv, strip, prepend('Foliation: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('material'), parse_csv, strip, prepend('Material: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('notes'), parse_csv, strip, prepend('Notes: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('script'), parse_csv, strip, prepend('Script: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('layout'), parse_csv, strip, prepend('Layout: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_dc_rights', column('attribution'), parse_csv, strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', column('extent'), parse_csv, strip, lang('en')
to_field 'cho_has_type', literal('Books'), lang('en')
to_field 'cho_has_type', literal('Books'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', column('format'), parse_csv, strip, lang('en')
to_field 'cho_identifier', column('classmark'), parse_csv, strip
to_field 'cho_language', column('languages'), parse_csv, split(';'), strip, normalize_language, lang('en')
to_field 'cho_language', column('languages'), parse_csv, split(';'), strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', column('provenance'), parse_csv, strip, lang('en')
to_field 'cho_provenance', column('former-owners'), parse_csv, strip, prepend('Former owners: '), lang('en')
to_field 'cho_spatial', column('origin-place'), parse_csv, strip, lang('en')
to_field 'cho_subject', column('subjects'), parse_csv, strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('id'), strip, gsub('https://cudl.lib.cam.ac.uk/iiif/', 'https://cudl.lib.cam.ac.uk/view/')]
  )
end

to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('preview'), parse_csv, strip]
  )
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
