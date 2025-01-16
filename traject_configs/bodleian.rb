# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
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
require 'macros/transformation'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
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

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('bodleian-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('bodleian-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('bodleian-')

# Cho Required
to_field 'id', extract_json('.id'),
         flatten_array,
         dlme_strip,
         dlme_gsub('https://iiif.bodleian.ox.ac.uk/iiif/manifest/', ''),
         dlme_gsub('.json', '')
to_field 'cho_title', extract_json('.title'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'und-Latn'), default_multi_lang('Untitled', 'بدون عنوان')

# Cho Other
to_field 'cho_alternate', extract_json('.other-titles'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.annotator'), flatten_array, dlme_strip, dlme_prepend('Annotator: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.author-of-introduction'), flatten_array, dlme_strip, dlme_prepend('Author of introduction: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.compiler'), flatten_array, dlme_strip, dlme_prepend('Compiler: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.commentators'), flatten_array, dlme_strip, dlme_prepend('Commentators: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.contributor'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.editors'), flatten_array, dlme_strip, dlme_prepend('Editor: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.illustrator'), flatten_array, dlme_strip, dlme_prepend('Illustrator: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.printer'), flatten_array, dlme_strip, dlme_prepend('Printer: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.scribe'), flatten_array, dlme_strip, dlme_prepend('Scribe: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_json('.translator'), flatten_array, dlme_strip, dlme_prepend('Translator: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_creator', extract_json('.author'), flatten_array, dlme_strip, dlme_prepend('Author: '), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_creator', extract_json('.creator'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_date', extract_json('.date-statement'), flatten_array, dlme_strip, lang('en')
to_field 'cho_date_range_norm', extract_json('.date-statement'), flatten_array, dlme_strip, dlme_gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', extract_json('.date-statement'), flatten_array, dlme_strip, dlme_gsub('/', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', literal('Photo: © Bodleian Libraries, University of Oxford, Terms of use: http://digital.bodleian.ox.ac.uk/terms.html'), lang('en')
to_field 'cho_description', extract_json('.binding'), flatten_array, dlme_strip, dlme_prepend('Binding: '), lang('en')
to_field 'cho_description', extract_json('.catalogue-description'), flatten_array, dlme_strip, lang('en')
to_field 'cho_description', extract_json('.collation'), flatten_array, dlme_strip, dlme_prepend('Collation: '), lang('en')
to_field 'cho_description', extract_json('.contents'), flatten_array, dlme_strip, dlme_prepend('Contents: '), lang('en')
to_field 'cho_description', extract_json('.contents-note'), flatten_array, dlme_strip, dlme_prepend('Contents note: '), lang('en')
to_field 'cho_description', extract_json('.decoration'), flatten_array, dlme_strip, dlme_prepend('Decoration: '), lang('en')
to_field 'cho_description', extract_json('.description'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_description', extract_json('.dimensions'), flatten_array, dlme_strip, dlme_prepend('Dimensions: '), lang('en')
to_field 'cho_description', extract_json('.hand'), flatten_array, dlme_strip, dlme_prepend('Hand: '), lang('en')
to_field 'cho_description', extract_json('.layout'), flatten_array, dlme_strip, dlme_prepend('Layout: '), lang('en')
to_field 'cho_description', extract_json('.origin-note'), flatten_array, dlme_strip, dlme_prepend('Origin note: '), lang('en')
to_field 'cho_description', extract_json('.record-origin'), flatten_array, dlme_strip, dlme_prepend('Record origin: '), lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.extent'), flatten_array, dlme_strip, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.catalogue-identifier'), flatten_array, dlme_strip
to_field 'cho_identifier', extract_json('.other-identifier'), flatten_array, dlme_strip
to_field 'cho_identifier', extract_json('.shelfmark'), flatten_array, dlme_strip
to_field 'cho_is_part_of', extract_json('.collection'), flatten_array, dlme_strip, lang('en')
to_field 'cho_language', extract_json('.language'), flatten_array, normalize_language, lang('en')
to_field 'cho_language', extract_json('.language'), flatten_array, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_medium', extract_json('.materials'), flatten_array, dlme_strip, lang('en')
to_field 'cho_publisher', extract_json('.publisher'), flatten_array, dlme_strip, lang('en')
to_field 'cho_provenance', extract_json('.former-owner'), flatten_array, dlme_strip, dlme_prepend('Former owner: '), lang('en')
to_field 'cho_provenance', extract_json('.provenance'), flatten_array, dlme_strip, lang('en')
to_field 'cho_relation', extract_json('.related-items'), flatten_array, dlme_strip, lang('en')
to_field 'cho_spatial', extract_json('.place-of-origin'), flatten_array, dlme_strip, lang('en')
to_field 'cho_subject', extract_json('.subject'), flatten_array, dlme_strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.rendering'), flatten_array, dlme_strip],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.thumbnail'), flatten_array, at_index(0), dlme_strip],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip]
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
  'dlme_collection',
  'agg_data_provider_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
