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
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('ucla-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('ucla-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('ucla-')

# CHO Required
to_field 'id', extract_json('.id'), gsub('https:\/\/iiif.library.ucla.edu\/iiif\/2\/', ''), gsub('\/!200,200\/0\/default.jpg', '')
to_field 'cho_title', extract_json('..title'), flatten_array, strip, armenian_script_lang_or_default('hy-Armn', 'en')

# CHO Other
to_field 'cho_alternative', extract_json('..alternative'), flatten_array, armenian_script_lang_or_default('hy-Armn', 'en')
to_field 'cho_creator', extract_json('..creator'), flatten_array, armenian_script_lang_or_default('hy-Armn', 'en')
to_field 'cho_contributor', extract_json('..contributor'), flatten_array, armenian_script_lang_or_default('hy-Armn', 'en')
to_field 'cho_date', extract_json('.date[0]'), strip, armenian_script_lang_or_default('hy-Armn', 'en')
to_field 'cho_date_range_norm', extract_json('.date[0]'), strip, parse_range
to_field 'cho_date_range_hijri', extract_json('.date[0]'), strip, parse_range, hijri_range
to_field 'cho_description', extract_json('..description'), flatten_array, armenian_script_lang_or_default('hy-Armn', 'en')
to_field 'cho_edm_type', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('ucla-'), translation_map('has_type_from_collection'), normalize_edm_type, lang('en')
to_field 'cho_edm_type', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('ucla-'), translation_map('has_type_from_collection'), normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('ucla-'), translation_map('has_type_from_collection'), normalize_has_type, lang('en')
to_field 'cho_has_type', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('ucla-'), translation_map('has_type_from_collection'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('..format'), flatten_array, lang('en')
to_field 'cho_identifier', extract_json('..identifier'), flatten_array
to_field 'cho_is_part_of', extract_json('..source'), flatten_array, armenian_script_lang_or_default('hy-Armn', 'en')
to_field 'cho_publisher', extract_json('..publisher'), flatten_array, armenian_script_lang_or_default('hy-Armn', 'en')
to_field 'cho_subject', extract_json('..subject'), flatten_array, armenian_script_lang_or_default('hy-Armn', 'en')
# UCLA requested to translated LoC urls to user-facing type values
to_field 'cho_type', extract_json('..type'), flatten_array, strip, translation_map('type_from_loc'), lang('en')

# Agg
to_field 'agg_data_provider', extract_json('.dataProvider[0]'), default('University of California, Los Angeles. Library. Department of Special Collections'), lang('en')
to_field 'agg_data_provider', extract_json('.dataProvider[0]'), default('University of California, Los Angeles. Library. Department of Special Collections'), translation_map('data_provider_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_country', extract_json('.dataProvider[0]'), default('University of California, Los Angeles. Library. Department of Special Collections'), translation_map('data_provider_to_country'), lang('en')
to_field 'agg_data_provider_country', extract_json('.dataProvider[0]'), default('University of California, Los Angeles. Library. Department of Special Collections'), translation_map('data_provider_to_country'), translation_map('country_en_to_ar'), lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.isShownAt[0]')],
    'wr_is_referenced_by' => [extract_json('identifier[-1]'), gsub('oai:library.ucla.edu:', ''), gsub(':', '%3A'), gsub('/', '%2F'), prepend('https://iiif.library.ucla.edu/'), append('/manifest')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.object[0]')],
    'wr_is_referenced_by' => [extract_json('identifier[-1]'), gsub('oai:library.ucla.edu:', ''), gsub(':', '%3A'), gsub('/', '%2F'), prepend('https://iiif.library.ucla.edu/'), append('/manifest')]
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
