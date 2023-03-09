# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/aub'
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
require 'traject_plus'

extend Macros::AUB
extend Macros::Collection
# extend Macros::Xml
extend Macros::DLME
extend Macros::DateParsing
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
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('aub-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('aub-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('aub-')

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_poha('//identifier'), prepend('aub-'), strip
to_field 'cho_title', extract_poha('//dc:title'), arabic_script_lang_or_default('ar-Arab', 'und-Latn'), default_multi_lang('Untitled', 'بدون عنوان')

# Cho Other
to_field 'cho_creator', extract_poha('//dc:interviewee'), strip, prepend('Interviewee: '), lang('en')
to_field 'cho_creator', extract_poha('//dc:interviewer'), strip, prepend('Interviewer: '), lang('en')
to_field 'cho_creator', extract_poha('//dc:intervieweeAR'), strip, prepend('الذي تجري معه المقابلة: '), lang('ar-Arab')
to_field 'cho_creator', extract_poha('//dc:interviewerAR'), strip, prepend('المحاور: '), lang('ar-Arab')
to_field 'cho_contributor', extract_poha('//dc:contributor'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date', extract_poha('//dc:date'), strip, lang('en')
to_field 'cho_date_range_hijri', extract_poha('//dc:date'), strip, parse_range, hijri_range
to_field 'cho_date_range_norm', extract_poha('//dc:date'), strip, parse_range
to_field 'cho_dc_rights', extract_poha('//dc:rights'), lang('en')
to_field 'cho_description', extract_poha('//dc:description'), strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_description', extract_poha('//dc:biography'), strip, prepend('Biography: '), lang('en')
to_field 'cho_description', extract_poha('//dc:biographyAR'), strip, prepend('سيرة شخصية: '), lang('ar-Arab')
to_field 'cho_description', extract_poha('//dc:otherF'), strip, prepend('Families: '), lang('en')
to_field 'cho_description', extract_poha('//dc:otherFAR'), strip, prepend('العائلات: '), lang('ar-Arab')
to_field 'cho_description', extract_poha('//dc:otherLPBI'), strip, prepend('Landmarks-Public Institutions: '), lang('en')
to_field 'cho_description', extract_poha('//dc:otherLPBIAR'), strip, prepend('معالم - مؤسسات عامة: '), lang('ar-Arab')
to_field 'cho_description', extract_poha('//dc:otherLPRI'), strip, prepend('Landmarks-Private Institutions: '), lang('en')
to_field 'cho_description', extract_poha('//dc:otherLPRIAR'), strip, prepend('المعالم - المؤسسات الخاصة: '), lang('ar-Arab')
to_field 'cho_description', extract_poha('//dc:otherLPW'), strip, prepend('Landmarks-Places of Worship: '), lang('en')
to_field 'cho_description', extract_poha('//dc:otherLPWAR'), strip, prepend('المعالم - دور العبادة: '), lang('ar-Arab')
to_field 'cho_description', extract_poha('//dc:otherSF'), strip, prepend('Significant figures: '), lang('en')
to_field 'cho_description', extract_poha('//dc:otherSFAR'), strip, prepend('الناس المهمين: '), lang('ar-Arab')
to_field 'cho_description', extract_poha('//dc:toc'), strip, prepend('Table of contents: '), lang('en')
to_field 'cho_description', extract_poha('//dc:tocAR'), strip, prepend('جدول المحتويات: '), lang('ar-Arab')
# We are intentionally not mapping edm_type from has_type since has type is always 'Oral History'
# and edm_type may be 'Video' or 'Sound'
to_field 'cho_edm_type', extract_poha('//dc:format'), first_only, translation_map('edm_type_from_provider'), lang('en')
to_field 'cho_edm_type', extract_poha('//dc:format'), first_only, translation_map('edm_type_from_provider'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_poha('//dc:duration'), strip, prepend('Duration: '), lang('en')
to_field 'cho_extent', extract_poha('//dc:duration'), strip, prepend('مدة: '), lang('ar-Arab')
to_field 'cho_format', extract_poha('//dc:format'), strip, lang('en')
to_field 'cho_has_type', literal('Oral History'), lang('en')
to_field 'cho_has_type', literal('Oral History'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_poha('//dc:identifier'), strip
to_field 'cho_is_part_of', extract_poha('//dc:relation'), strip, lang('en')
to_field 'cho_language', extract_poha('//dc:language'), split(';'),
         split(','), strip, normalize_language, lang('en')
to_field 'cho_language', extract_poha('//dc:language'), split(';'),
         split(','), strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_publisher', extract_poha('//dc:publisher'), strip, lang('en')
to_field 'cho_spatial', extract_poha('//dc:village'), prepend('Village: '), lang('en')
to_field 'cho_spatial', extract_poha('//dc:villageAR'), prepend('قرية: '), lang('ar-Arab')
to_field 'cho_subject', extract_poha('//dc:otherSubject'), split(';'), strip, lang('en')
to_field 'cho_subject', extract_poha('//dc:subject'), strip, lang('en')
to_field 'cho_subject', extract_poha('//dc:subjectAR'), strip, lang('ar-Arab')
to_field 'cho_type', extract_poha('//dc:type'), arabic_script_lang_or_default('ar-Arab', 'und-Latn')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_poha('rights')],
    'wr_edm_rights' => [literal('CC BY-ND: https://creativecommons.org/licenses/by-nd/4.0/')],
    'wr_id' => [extract_poha('//dc:identifierURI'), strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_poha('rights')],
    'wr_edm_rights' => [literal('CC BY-ND: https://creativecommons.org/licenses/by-nd/4.0/')],
    'wr_id' => [extract_poha('//dc:thumbnail')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider',
  'agg_data_provider_collection',
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
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
