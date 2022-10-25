# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/iiif'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
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
extend Macros::IIIF
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
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

to_field 'agg_data_provider_collection', literal('qnl'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('qnl'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('qnl')

# each_record do |record, context|
#   context.clipboard[:id] = generate_qnl_iiif_id(record, context)
#   context.clipboard[:manifest] = "https:__www.qdl.qa_en_iiif_#{context.clipboard[:id]}_manifest"
# end

# CHO Required
to_field 'id', column('id'), parse_csv, at_index(0), gsub('_ar', '_dlme'), gsub('_en', '_dlme')
# 'titleInfo_title' has mixed language content, don't use arabic_script_lang_or_default macro
to_field 'cho_title', column('title'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')

# CHO Other
to_field 'cho_creator', column('author'), parse_csv, strip, gsub('NOT PROVIDED', ''), prepend('Author: '), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date', column('originInfo_dateIssued'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_norm', column('originInfo_dateIssued'), parse_csv, strip, gsub('_', '-'), parse_range
to_field 'cho_date_range_hijri', column('originInfo_dateIssued'),
         parse_csv, strip, gsub('_', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', column('accessCondition'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')
# 'abstract' has mixed language content, don't use arabic_script_lang_or_default macro
to_field 'cho_description', column('abstract'), parse_csv, at_index(0), strip, prepend('ملخص: '), lang('ar-Arab')
to_field 'cho_description', column('abstract'), parse_csv, at_index(1), strip, prepend('Abstract: '), lang('en')
# 'physicalDescription_extent' has mixed language content, don't use arabic_script_lang_or_default macro
to_field 'cho_description', column('physicalDescription_extent'), parse_csv, at_index(0), strip, prepend('الوصف المادي: '), lang('ar-Arab')
to_field 'cho_description', column('physicalDescription_extent'), parse_csv, at_index(1), strip, prepend('Physical description: '), lang('ar-Arab')
to_field 'cho_edm_type', column('genre'), parse_csv, at_index(1), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', column('genre'), parse_csv, at_index(1), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', column('genre'), parse_csv, at_index(1), normalize_has_type, lang('en')
to_field 'cho_has_type', column('genre'), parse_csv, at_index(1), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('identifier'), parse_csv, strip
to_field 'cho_identifier', column('location_shelfLocator'), parse_csv, strip
to_field 'cho_is_part_of', column('location_physicalLocation'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_language', column('language_languageTerm'), parse_csv, at_index(0), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', column('language_languageTerm'), parse_csv, at_index(0), normalize_language, lang('en')
to_field 'cho_spatial', column('subject_geographic'), parse_csv, strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', column('subject_topic'), parse_csv, strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', column('subject_name_namePart'), parse_csv, strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', column('genre'), parse_csv, strip, arabic_script_lang_or_default('ar-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [column('accessCondition'), parse_csv, strip],
    'wr_edm_rights' => [column('accessCondition'), parse_csv, strip, translation_map('edm_rights_from_contributor')],
    'wr_format' => [literal('image/jpeg')],
    'wr_id' => [column('id'), parse_csv, at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/archive/')],
    'wr_is_referenced_by' => [column('id'), parse_csv, at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/iiif/'), append('/manifest')]
  )
end
to_field 'agg_is_shown_by' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [column('accessCondition'), parse_csv, strip, translation_map('edm_rights_from_contributor')],
    'wr_format' => literal('image/jpeg'),
    'wr_id' => [column('shown_at'), parse_csv, strip, at_index(0)],
    'wr_is_referenced_by' => [column('id'), parse_csv, at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/iiif/'), append('/manifest')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [column('accessCondition'), parse_csv, strip, translation_map('edm_rights_from_contributor')],
    'wr_format' => [literal('image/jpeg')],
    'wr_id' => [column('preview'), parse_csv, strip, at_index(0)],
    'wr_is_referenced_by' => [column('id'), parse_csv, at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/iiif/'), append('/manifest')]
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
