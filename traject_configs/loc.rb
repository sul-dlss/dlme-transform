# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/iiif'
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
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::IIIF
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
extend TrajectPlus::Macros::JSON

settings do
  provide 'allow_duplicate_values', false
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('loc'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('loc'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('loc')

# CHO Required
to_field 'id', extract_json('.id'), strip, gsub('http://www.loc.gov/item/', ''), gsub('http:', ''), gsub('www.loc.gov', ''), gsub('/', ''), prepend('loc-')
to_field 'cho_title', extract_json('.title'), strip, arabic_script_lang_or_default('und-Arab', 'en')

# CHO Other
to_field 'cho_date', extract_json('.date'), lang('en')
to_field 'cho_date_range_norm', extract_json('.date'), parse_range
to_field 'cho_date_range_hijri', extract_json('.date'), parse_range, hijri_range
to_field 'cho_description', extract_json('.description[0]'), strip, lang('en')
to_field 'cho_description', extract_json('.description[1]'), strip, lang('en')
to_field 'cho_description', extract_json('.description[2]'), strip, lang('en')
# mixed types (array and string) in .identifier values causing errors
# to_field 'cho_identifier', extract_json('.identifier'), strip, lang('en')\to_field 'cho_has_type', extract_json('.type[0]'), normalize_has_type, lang('en')
to_field 'cho_edm_type', extract_json('.type[0]'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.type[0]'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('.format[0]'), strip, lang('en')
to_field 'cho_format', extract_json('.format[1]'), strip, lang('en')
to_field 'cho_has_type', extract_json('.type[0]'), normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.type[0]'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.language[0]'), normalize_language, lang('en')
to_field 'cho_language', extract_json('.language[0]'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.language[1]'), normalize_language, lang('en')
to_field 'cho_language', extract_json('.language[1]'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_spatial', extract_json('.location_country[0]'), strip, lang('en')
to_field 'cho_spatial', extract_json('.location_country[1]'), strip, lang('en')
to_field 'cho_subject', extract_json('.subject[0]'), strip, lang('en')
to_field 'cho_subject', extract_json('.subject[1]'), strip, lang('en')
to_field 'cho_type', extract_json('.type[0]'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.shown_at')],
    'wr_is_referenced_by' => [extract_json('.id'), strip, gsub('http', 'https'), append('manifest.json')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.preview[0]')],
    'wr_is_referenced_by' => [extract_json('.id'), strip, gsub('http', 'https'), append('manifest.json')]
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
