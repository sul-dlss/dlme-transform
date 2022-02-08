# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/cambridge'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/path_to_file'
require 'macros/string_helper'
require 'macros/tei'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Cambridge
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::PathToFile
extend Macros::StringHelper
extend Macros::Tei
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Tei
extend TrajectPlus::Macros::Xml

settings do
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

each_record do |record, context|
  context.clipboard[:id] = extract_record_id(record)
end

to_field 'agg_data_provider_collection', literal('cambridge-hebrew'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', literal('cambridge-hebrew'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('cambridge-hebrew')

# File path
to_field 'dlme_source_file', path_to_file

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Cho Required
to_field 'id', lambda { |_record, accumulator, context|
  bare_id = default_identifier(context)
  accumulator << identifier_with_prefix(context, bare_id)
}
to_field 'cho_title', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:title[1]"), squish, default('Untitled', 'بدون عنوان'), lang('en')

# Cho other
to_field 'cho_alternative', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:title[@type='alt']"), squish, hebrew_script_lang_or_default('he', 'en')
to_field 'cho_creator', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:author"), strip, lang('en')
to_field 'cho_date', extract_tei("#{MS_DESC}/#{MS_ORIGIN}/tei:origDate"), squish, strip, lang('en')
to_field 'cho_date_range_norm', cambridge_gregorian_range
to_field 'cho_date_range_hijri', cambridge_gregorian_range, hijri_range
to_field 'cho_dc_rights', extract_tei("#{PUB_STMT}/tei:availability/tei:licence"), squish, strip, lang('en')
to_field 'cho_description', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/tei:summary"), squish, strip, lang('en')
to_field 'cho_description', return_or_prepend("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:condition", 'Condition:'), squish, strip, lang('en')
to_field 'cho_description', return_or_prepend("#{MS_DESC}/#{OBJ_DESC}/tei:layoutDesc/tei:layout", 'Layout:'), squish, strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', cambridge_dimensions, squish, lang('en')
to_field 'cho_format', extract_tei("#{MS_DESC}/#{OBJ_DESC}/@form"), strip, titleize, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), strip, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), strip, lang('ar-Arab')
to_field 'cho_identifier', extract_tei("#{MS_DESC}/#{MS_ID}/tei:idno"), strip
to_field 'cho_is_part_of', literal('Hebrew Manuscripts Collection'), lang('en')
to_field 'cho_language', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:textLang/@mainLang"), strip, split(' '), normalize_language, lang('en')
to_field 'cho_language', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:textLang/@otherLangs"), strip, split(' '), normalize_language, lang('en')
to_field 'cho_language', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:textLang/@mainLang"), strip, split(' '), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:textLang/@otherLangs"), strip, split(' '), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_medium', extract_tei("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:support"), squish, strip, lang('en')
to_field 'cho_provenance', extract_tei("#{MS_DESC}/tei:history/tei:provenance"), squish, strip, lang('en')
to_field 'cho_publisher', extract_tei("#{PUB_STMT}/tei:publisher"), strip, lang('en')
to_field 'cho_spatial', extract_tei("#{MS_DESC}/#{MS_ORIGIN}/tei:origPlace"), strip, lang('en')
to_field 'cho_subject', extract_tei("#{PROFILE_DESC}/tei:keywords[@n='form/genre']/tei:term"), strip, lang('en')
to_field 'cho_subject', extract_tei("#{PROFILE_DESC}/tei:keywords[@n='subjects']/tei:term"), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_dc_rights', extract_tei("#{PUB_STMT}/tei:availability/tei:licence"), squish, strip
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_dc_rights' => [extract_tei("#{PUB_STMT}/tei:availability/tei:licence"), first_only, squish, strip],
                                  'wr_edm_rights' => [literal('BY-NC-SA'), translation_map('edm_rights_from_contributor')],
                                  'wr_id' => [literal(context.clipboard[:id]),
                                              prepend('https://cudl.lib.cam.ac.uk/view/'),
                                              append('/1')],
                                  'wr_is_referenced_by' => [literal(context.clipboard[:id]),
                                                            prepend('https://cudl.lib.cam.ac.uk/iiif/')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_dc_rights' => [extract_tei("#{PUB_STMT}/tei:availability/tei:licence"), first_only, squish, strip],
                                  'wr_edm_rights' => [literal('BY-NC-SA'), translation_map('edm_rights_from_contributor')],
                                  'wr_id' => [extract_tei('//tei:facsimile/tei:graphic/@url'),
                                              gsub('http://cudl.lib.cam.ac.uk/content/images/', ''),
                                              gsub(%r{_files/8/0_0.jpg}, ''),
                                              append('.jp2'),
                                              prepend('https://images.lib.cam.ac.uk/iiif/'),
                                              append('/full/!400,400/0/default.jpg')],
                                  'wr_is_referenced_by' => [literal(context.clipboard[:id]),
                                                            prepend('https://cudl.lib.cam.ac.uk/iiif/')])
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
