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

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-')

# Cho Required
to_field 'id', column('identifier'), split('alt='), first_only, parse_csv, strip, gsub("<a href='http://arks.princeton.edu/", ''), gsub("'", '')
# uniform_title is not being used but should be if authority control is applied to title field
to_field 'cho_title', column('title'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_title', column('uniform-title'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')

# Cho Other
to_field 'cho_alternative', column('alternative'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_creator', column('author'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_creator', column('creator'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', column('contributor'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', column('director'), parse_csv, strip, prepend('Director: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_contributor', column('rendered-actors'), parse_csv, strip, prepend('Actor: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_date', column('date'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_norm', column('date'), parse_csv, strip, parse_range
to_field 'cho_date_range_hijri', column('date'), parse_csv, strip, parse_range, hijri_range
to_field 'cho_date', column('date-created'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_norm', column('date-created'), parse_csv, strip, parse_range
to_field 'cho_date_range_hijri', column('date-created'), parse_csv, strip, parse_range, hijri_range
to_field 'cho_dc_rights', literal('https://rbsc.princeton.edu/services/imaging-publication-services'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('abstract'), parse_csv, strip, prepend('Abstract: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('binding-note'), parse_csv, strip, prepend('Binding note: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('contents'), parse_csv, strip, prepend('Contents: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', column('description'), parse_csv, strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', column('extent'), parse_csv, strip, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('call-number'), parse_csv, strip
to_field 'cho_identifier', column('identifier'), parse_csv, strip
to_field 'cho_identifier', column('local-identifier'), parse_csv, strip
to_field 'cho_identifier', column('replaces'), parse_csv, strip, prepend('Replaces: ')
to_field 'cho_is_part_of', column('member-of-collections'), parse_csv, strip, lang('en')
to_field 'cho_language', column('language'), parse_csv, gsub('.', ''), strip, normalize_language, lang('en')
to_field 'cho_language', column('language'), parse_csv, gsub('.', ''), strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', column('text-language'), parse_csv, gsub('.', ''), strip, normalize_language, lang('en')
to_field 'cho_language', column('text-language'), parse_csv, gsub('.', ''), strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', column('provenance'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_publisher', column('publisher'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_spatial', column('geographic-origin'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', column('genre'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', column('subject'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_type', column('resource-type'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_type', column('type'), parse_csv, strip, arabic_script_lang_or_default('und-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('identifier'), split("href='"), last, split("' alt='"), first_only, parse_csv, strip],
                                  'wr_is_referenced_by' => column('id'))
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('thumbnail'), parse_csv, first_only, split('/full/'), strip, append('/full/!400,400/0/default.jpg')],
                                  'wr_is_referenced_by' => column('id'))
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
