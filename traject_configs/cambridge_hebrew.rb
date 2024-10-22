# frozen_string_literal: true

require 'dlme_debug_writer'
require 'dlme_json_resource_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/timestamp'
require 'macros/transformation'
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
extend Macros::Timestamp
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

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('cambridge-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('cambridge-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('cambridge-')

# Cho Required
to_field 'id', extract_json('.id'), dlme_gsub('https://cudl.lib.cam.ac.uk/iiif/', ''), dlme_strip
to_field 'cho_title', extract_json('.title'), flatten_array, dlme_strip, hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('.uniform-title'), flatten_array, dlme_strip, hebrew_script_lang_or_default('ar-Arab', 'en')

# Cho Other
to_field 'cho_alternative', extract_json('.alternative-titles'), flatten_array, dlme_strip, lang('en')
to_field 'cho_contributor', extract_json('.associated-names'), flatten_array, dlme_strip, dlme_prepend('Scribes: '), lang('en')
to_field 'cho_contributor', extract_json('.scribes'), flatten_array, dlme_strip, dlme_prepend('Scribes: '), lang('en')
to_field 'cho_creator', extract_json('.authors'), flatten_array, dlme_strip, lang('en')
to_field 'cho_date_range_hijri', extract_json('.date-of-creation'), flatten_array, dlme_strip, parse_range, hijri_range
to_field 'cho_date_range_norm', extract_json('.date-of-creation'), flatten_array, dlme_strip, parse_range
to_field 'cho_date', extract_json('.date-of-creation'), flatten_array, dlme_strip, lang('en')
to_field 'cho_dc_rights', extract_json('.attribution'), flatten_array, dlme_strip, lang('en')
to_field 'cho_description', extract_json('.abstract'), flatten_array, dlme_strip, dlme_prepend('Abstract: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.additions'), flatten_array, dlme_strip, dlme_prepend('Abstract: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.binding'), flatten_array, dlme_strip, dlme_prepend('Binding: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.condition'), flatten_array, dlme_strip, dlme_prepend('Condition: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.decoration'), flatten_array, dlme_strip, dlme_prepend('Decoration: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.description'), flatten_array, dlme_split('/'), dlme_strip, hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.foliation'), flatten_array, dlme_strip, dlme_prepend('Foliation: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.layout'), flatten_array, dlme_strip, dlme_prepend('Layout: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.material'), flatten_array, dlme_strip, dlme_prepend('Material: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.notes'), flatten_array, dlme_strip, dlme_prepend('Notes: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.script'), flatten_array, dlme_strip, dlme_prepend('Script: '), hebrew_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('.extent'), flatten_array, dlme_strip, lang('en')
to_field 'cho_format', extract_json('.format'), flatten_array, dlme_strip, lang('en')
to_field 'cho_has_type', literal('Books'), lang('en')
to_field 'cho_has_type', literal('Books'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.classmark'), flatten_array, strip
to_field 'cho_language', extract_json('.languages'), flatten_array, dlme_split(';'), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.languages'), flatten_array, dlme_split(';'), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.former-owners'), flatten_array, dlme_strip, dlme_prepend('Former owners: '), lang('en')
to_field 'cho_provenance', extract_json('.provenance'), flatten_array, dlme_strip, lang('en')
to_field 'cho_spatial', extract_json('.origin-place'), flatten_array, dlme_strip, lang('en')
to_field 'cho_subject', extract_json('.subjects'), flatten_array, dlme_strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.id'), dlme_strip, dlme_gsub('https://cudl.lib.cam.ac.uk/iiif/', 'https://cudl.lib.cam.ac.uk/view/')]
  )
end

to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.preview'), flatten_array, dlme_strip]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider_collection',
  'agg_data_provider_country',
  'agg_data_provider',
  'agg_provider_country',
  'agg_provider',
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
