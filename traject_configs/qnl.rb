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
require 'macros/qnl'
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
extend Macros::QNL
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

to_field 'agg_data_provider_collection', literal('qnl'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('qnl'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('qnl')

# CHO Required
to_field 'id', extract_json('.id'), gsub('_ar', '_dlme'), gsub('_en', '_dlme')
to_field 'cho_title', extract_json('.title[0]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('.title[1]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')

# CHO Other
to_field 'cho_alternative', extract_json('.title_alternative[0]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_alternative', extract_json('.title_alternative[1]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_creator', extract_json('.author[0]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Author: ', 'مؤلف: ')
to_field 'cho_creator', extract_json('.author[1]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Author: ', 'مؤلف: ')
to_field 'cho_creator', extract_json('.cartographer[0]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Cartographer: ', 'رسام خرائط: ')
to_field 'cho_creator', extract_json('.cartographer[1]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Cartographer: ', 'رسام خرائط: ')
to_field 'cho_date', extract_json('.originInfo_dateIssued[0]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_norm', extract_json('.originInfo_dateIssued[0]'), strip, gsub('_', '-'), parse_range
to_field 'cho_date_range_hijri', extract_json('.originInfo_dateIssued[0]'), strip, gsub('_', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('.accessCondition[0]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('.abstract[0]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Abstract: ', 'ملخص: ')
to_field 'cho_description', extract_json('.abstract[1]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Abstract: ', 'ملخص: ')
to_field 'cho_description', extract_json('.physicalDescription_extent[0]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Physical description: ', 'الوصف المادي: ')
to_field 'cho_description', extract_json('.physicalDescription_extent[1]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Physical description: ', 'الوصف المادي: ')
to_field 'cho_edm_type', extract_json('.genre[0]'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.genre[0]'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', extract_json('.genre[0]'), normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.genre[0]'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_edm_type', extract_json('.genre[1]'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.genre[1]'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', extract_json('.genre[1]'), normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.genre[1]'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.identifier[0]'), strip
to_field 'cho_identifier', extract_json('.location_shelfLocator[0]'), strip
to_field 'cho_is_part_of', extract_json('.location_physicalLocation[0]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_language', extract_json('.language_languageTerm[0]'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('.language_languageTerm[0]'), normalize_language, lang('en')
to_field 'cho_publisher', extract_json('.publisher[0]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Publisher: ', 'الناشر: ')
to_field 'cho_publisher', extract_json('.publisher[1]'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Publisher: ', 'الناشر: ')
to_field 'cho_spatial', extract_json('.subject_geographic[0]'), strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('.subject_geographic[1]'), strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('.subject_topic[0]'), strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('.subject_topic[1]'), strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('.subject_name_namePart[0]'), strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('.subject_name_namePart[1]'), strip, gsub('NOT PROVIDED', ''), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', extract_json('.genre[0]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', extract_json('.genre[1]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.accessCondition[0]'), at_index(0), strip],
    'wr_edm_rights' => [extract_json('.accessCondition[0]'), at_index(0), strip, translation_map('edm_rights_from_contributor')],
    'wr_format' => [literal('image/jpeg')],
    'wr_id' => [extract_json('.id'), at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/archive/')],
    'wr_is_referenced_by' => [extract_json('.id'), at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/iiif/'), append('/manifest')]
  )
end
to_field 'agg_is_shown_by' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [extract_json('.accessCondition[0]'), at_index(0), strip, translation_map('edm_rights_from_contributor')],
    'wr_format' => literal('image/jpeg'),
    'wr_id' => [extract_json('.shown_at[0]'), at_index(0), strip],
    'wr_is_referenced_by' => [extract_json('.id'), at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/iiif/'), append('/manifest')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [extract_json('.accessCondition[0]'), at_index(0), strip, translation_map('edm_rights_from_contributor')],
    'wr_format' => [literal('image/jpeg')],
    'wr_id' => [extract_json('.preview[0]'), at_index(0), strip, default('https://raw.githubusercontent.com/sul-dlss/dlme/main/app/assets/images/default.png')],
    'wr_is_referenced_by' => [extract_json('.id'), at_index(0), gsub('_ar', ''), gsub('_en', ''), prepend('https://www.qdl.qa/en/iiif/'), append('/manifest')]
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
