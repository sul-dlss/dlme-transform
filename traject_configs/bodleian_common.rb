# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/csv'
require 'macros/collection'
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

extend Macros::Csv
extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
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
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', column('id'),
         strip,
         gsub('https://iiif.bodleian.ox.ac.uk/iiif/manifest/', ''),
         gsub('.json', '')
to_field 'cho_title', column('title'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn'), default('Untitled', 'بدون عنوان')

# Cho Other
to_field 'cho_alternate', column('other-titles'), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('annotator'), strip, prepend('Annotator: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('commentators'), strip, prepend('Commentator: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('compiler'), strip, prepend('Compiler: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('contributor'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('editors'), strip, prepend('Editor: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('illustrator'), strip, append('Illustrator: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('printer'), strip, prepend('Printer: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('scribe'), strip, append('Scribe: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', column('translator'), strip, append('Translator: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_creator', column('author'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_date', column('date-statement'), strip, lang('en')
to_field 'cho_date_range_norm', column('date-statement'), strip, gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', column('date-statement'), strip, gsub('/', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', literal('Photo: © Bodleian Libraries, University of Oxford, Terms of use: http://digital.bodleian.ox.ac.uk/terms.html'), lang('en')
to_field 'cho_description', column('additional-information-sources'), strip, prepend('Additional sources: '), lang('en')
to_field 'cho_description', column('binding'), strip, prepend('Binding: '), lang('en')
to_field 'cho_description', column('contents'), strip, prepend('Contents: '), lang('en')
to_field 'cho_description', column('contents-note'), strip, prepend('Contents note: '), lang('en')
to_field 'cho_description', column('decoration'), strip, prepend('Decoration: '), lang('en')
to_field 'cho_description', column('description'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_description', column('dimensions'), strip, prepend('Dimensions: '), lang('en')
to_field 'cho_description', column('hand'), strip, prepend('Hand: '), lang('en')
to_field 'cho_description', column('layout'), strip, prepend('Layout: '), lang('en')
to_field 'cho_description', column('origin-note'), strip, prepend('Origin note: '), lang('en')
to_field 'cho_description', column('record-origin'), strip, prepend('Record origin: '), lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', column('extent'), strip, lang('en')
to_field 'cho_identifier', column('catalogue-identifier'), strip
to_field 'cho_is_part_of', column('collection'), strip, lang('en')
to_field 'cho_language', column('language'), parse_csv, normalize_language, lang('en')
to_field 'cho_language', column('language'), parse_csv, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_medium', column('materials'), strip, lang('en')
to_field 'cho_spatial', column('place-of-origin'), strip, lang('en')
to_field 'cho_subject', column('subject'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('rendering'), strip],
    'wr_is_referenced_by' => [column('id')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('thumbnail'), parse_csv, at_index(0), strip],
    'wr_is_referenced_by' => [column('id')]
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
