# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/newcastle'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::Newcastle
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

to_field 'agg_data_provider_collection', literal('gertrude-bell-archive'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('gertrude-bell-archive'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('gertrude-bell-archive')

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', extract_json('.id'), strip, prepend('newcastle-')
to_field 'cho_title', extract_json('.title'), arabic_script_lang_or_default('ar-Arab', 'und-Latn')

# CHO Other
to_field 'cho_creator', extract_json('.creator'), lang('en')
to_field 'cho_date', extract_json('.creation_date'), lang('en')
to_field 'cho_date_range_norm', extract_json('.creation_date'), parse_range
to_field 'cho_date_range_hijri', extract_json('.creation_date'), parse_range, hijri_range
to_field 'cho_dc_rights', literal('High Resolution images for reuse are available on request. Please complete the form on each image page or contact us. Please note that processing fees apply. Where re-using, we ask that you acknowledge in the following form: [insert full item reference], Bell (Gertrude) Archive, Newcastle University Library. Where copyright restrictions do still apply, as indicated against an item, please get in touch.'), lang('en')
to_field 'cho_description', extract_json('.description'), lang('en')
to_field 'cho_edm_type', extract_json('.type'), lang('en')
to_field 'cho_edm_type', extract_json('.type'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.extent'), lang('en')
to_field 'cho_has_type', extract_json('.type'), lang('en')
to_field 'cho_has_type', extract_json('.type'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.language'), normalize_language, lang('en')
to_field 'cho_language', extract_json('.language'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_spatial', extract_json('.country_and_region'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.shown_at')],
    'wr_is_referenced_by' => [extract_json('.iiif_manifest')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [newcastle_thumbnail, default('https://cdm21051.contentdm.oclc.org/iiif/2/p21051coll46:11076/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [extract_json('.iiif_manifest')]
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
