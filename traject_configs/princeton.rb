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

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('princeton-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('princeton-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('princeton-')

# Cho Required
to_field 'id', extract_json('.id'), flatten_array, dlme_split('/'), at_index(-2), dlme_strip
to_field 'cho_title', extract_json('.title[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_title', extract_json('.uniform-title[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')

# Cho Other
to_field 'cho_alternative', extract_json('.alternative[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_creator', extract_json('.author[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_creator', extract_json('.creator[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.artist[0]'), flatten_array, dlme_strip, dlme_prepend('Artist: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.abridger[0]'), flatten_array, dlme_strip, dlme_prepend('Abridger: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.annotator[0]'), flatten_array, dlme_strip, dlme_prepend('Annotator: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.calligrapher[0]'), flatten_array, dlme_strip, dlme_prepend('Calligrapher: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.compiler[0]'), flatten_array, dlme_strip, dlme_prepend('Compiler: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('..contributor'), flatten_array, flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.director[0]'), flatten_array, dlme_strip, dlme_prepend('Director: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_contributor', extract_json('.rendered-actors[0]'), flatten_array, dlme_strip, dlme_prepend('Actor: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.scribe[0]'), flatten_array, dlme_strip, dlme_prepend('Scribe: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.translator[0]'), flatten_array, dlme_strip, dlme_prepend('Translator: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_date', extract_json('.date[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_norm', extract_json('.date[0]'), flatten_array, dlme_strip, parse_range
to_field 'cho_date_range_hijri', extract_json('.date[0]'), flatten_array, dlme_strip, parse_range, hijri_range
to_field 'cho_date', extract_json('.date-created[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_norm', extract_json('.date-created[0]'), flatten_array, dlme_strip, parse_range
to_field 'cho_date_range_hijri', extract_json('.date-created[0]'), flatten_array, dlme_strip, parse_range, hijri_range
to_field 'cho_dc_rights', literal('https://rbsc.princeton.edu/services/imaging-publication-services'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.abstract[0]'), flatten_array, dlme_strip, dlme_prepend('Abstract: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.binding-note[0]'), flatten_array, dlme_strip, dlme_prepend('Binding note: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.contents[0]'), flatten_array, dlme_strip, dlme_prepend('Contents: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.description[0]'), flatten_array, dlme_strip, lang('en')
to_field 'cho_edm_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('princeton-'), translation_map('has_type_from_collection'), translation_map('edm_type_from_has_type'), lang('en')
to_field 'cho_edm_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('princeton-'), translation_map('has_type_from_collection'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.extent[0]'), flatten_array, dlme_strip, lang('en')
to_field 'cho_has_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('princeton-'), translation_map('has_type_from_collection'), lang('en')
to_field 'cho_has_type', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('princeton-'), translation_map('has_type_from_collection'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.call-number[0]'), flatten_array, dlme_strip
to_field 'cho_identifier', extract_json('.identifier[0]'), flatten_array, dlme_strip
to_field 'cho_identifier', extract_json('.local-identifier[0]'), flatten_array, dlme_strip
to_field 'cho_identifier', extract_json('.replaces[0]'), flatten_array, dlme_strip, dlme_prepend('Replaces: ')
to_field 'cho_is_part_of', extract_json('.member-of-collections[0]'), flatten_array, dlme_strip, lang('en')
# Leaving out the 'text-language' column because its mostly redundant.
to_field 'cho_language', extract_json('.language[0]'), flatten_array, dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.language[0]'), flatten_array, dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.collector[0]'), flatten_array, dlme_prepend('Collector: [0]'), dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_provenance', extract_json('.former-owner[0]'), flatten_array, dlme_prepend('Former owner: [0]'), dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_provenance', extract_json('.provenance[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_publisher', extract_json('.publisher[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_spatial', extract_json('.geographic-origin[0]'), dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.genre[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.subject[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_type', extract_json('.resource-type[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_type', extract_json('.type[0]'), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.identifier'), flatten_array, dlme_split("Identifier'>"), last, dlme_split('</a>'), first_only, dlme_strip],
                                  'wr_is_referenced_by' => [extract_json('.id'), flatten_array])
end
# One record is missing 'thumbnail' value. To get around that, we pass a generic thumnail image to `dlme_default`.
# This should be removed once Princeton fixes the data issue.
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.thumbnail[0]'), flatten_array, first_only, dlme_split('/full/'), dlme_strip, dlme_append('/full/!400,400/0/dlme_default.jpg'), dlme_default('https://iiif-cloud.princeton.edu/iiif/2/ce%2Fa3%2F3e%2Fcea33ed8c16141de94a3414f38290306%2Fintermediate_file/full/!400,400/0/dlme_default.jpg')],
                                  'wr_is_referenced_by' => [extract_json('.id'), flatten_array])
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
