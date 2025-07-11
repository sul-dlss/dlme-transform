# frozen_string_literal: true

## Frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/eastview'
require 'macros/iiif'
require 'macros/jaraid'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/transformation'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::Eastview
extend Macros::IIIF
extend Macros::Jaraid
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

## File path
to_field 'dlme_source_file', path_to_file
to_field 'dlme_project', literal('dlme-serials')

to_field 'agg_data_provider_collection', literal('Eastview Middle East Serials'), lang('en')
to_field 'agg_data_provider_collection', literal('مسلسلات إيست فيو الشرق الأوسط'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('eastview-serials')

# CHO Required
# This is the correct line
to_field 'id', generate_eastview_issue_id('F001', 'issue-url')
to_field 'cho_title', extract_json('.issue-text'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_title', extract_json('.F245'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_title', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_title, arabic_script_lang_or_default('und-Arab', 'en')

# CHO Other
to_field 'cho_contributor', extract_json('.F700'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.F710'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_creator', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_editors, lang('en')
to_field 'cho_creator', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_editors_ar, lang('ar-Arab')
to_field 'cho_date', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_pub_dates, dlme_prepend('Series publication dates: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_date', jaraid_issue_date, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_date_range_norm', jaraid_issue_date, dlme_strip, parse_range
to_field 'cho_date_range_hijri', jaraid_issue_date, dlme_strip, parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('.F506'), flatten_array, lang('en')
to_field 'cho_dc_rights', extract_json('.F540'), flatten_array, lang('en')
to_field 'cho_dc_rights', extract_json('.F542'), flatten_array, lang('en')
to_field 'cho_description', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_notes('comment'), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_description', extract_json('.F520'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_description', extract_json('.F500'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_description', extract_json('.F490'), flatten_array, dlme_prepend('Series statement: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.F300'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_has_type', literal('Serials'), lang('en')
to_field 'cho_has_type', literal('Serials'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('.F336'), flatten_array, lang('en')
to_field 'cho_format', extract_json('.F337'), flatten_array, lang('en')
to_field 'cho_identifier', extract_json('.F001'), translation_map('jaraid_from_eastview'), flatten_array
to_field 'cho_identifier', extract_json('.F001'), flatten_array
to_field 'cho_identifier', extract_json('.F035'), flatten_array
to_field 'cho_is_part_of', extract_json('.F830'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_language', extract_json('.F041'), flatten_array, dlme_split(' '), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.F041'), flatten_array, dlme_split(' '), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_publisher', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_publishers, lang('en')
to_field 'cho_publisher', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_publishers_ar, lang('ar-Arab')
to_field 'cho_publisher', extract_json('.F246'), flatten_array, dlme_gsub('880-02 ', ''), dlme_split(':'), at_index(1), dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_spatial', extract_json('.F546'), translation_map('jaraid_from_eastview'), jaraid_pub_places, lang('en')
to_field 'cho_spatial', extract_json('.F546'), translation_map('jaraid_from_eastview'), jaraid_pub_places_ar, lang('ar-Arab')
to_field 'cho_spatial_coordinates', extract_json('.F001'), translation_map('jaraid_from_eastview'), jaraid_place_refs_from_id, jaraid_coordinates_from_pubplace
to_field 'cho_subject', extract_json('.F610'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F650'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F651'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F653'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F655'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.issue-url')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.preview'), dlme_gsub('&width=600', '&width=400')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

# Ignored Fields
## F003
## F005
## F006
## F007
## F008
## F010
## F040
## F042
## F043
## F050
## F082
## F130
## F260
## F264
## F310
## F321
## F338
## F362
## F515
## F525
## F538
## F550
## F580
## F588
## F740
## F752
## F856
## F856-norm
## F880

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
