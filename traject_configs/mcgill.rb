# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
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
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::FieldExtraction
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

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('mcgill-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('mcgill-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('mcgill-')

# Cho Required
to_field 'id', extract_json('.001'), flatten_array, dlme_strip
to_field 'cho_title', extract_json('.245_a'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), default_multi_lang('Untitled', 'بدون عنوان')

# Cho Other
to_field 'cho_alternate', extract_json('.240_a'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_alternate', extract_json('.246_a'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_alternate', extract_json('.880_c'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_creator', extract_person_date_role('.100_a', '.100_d', '.100_e'), flatten_array, dlme_strip, dlme_gsub('.', ''), arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_creator', extract_person_date_role('.880_a', '.880_d', '.880_e'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_date', extract_json('.264_c'), flatten_array, dlme_strip, lang('en')
to_field 'cho_date_range_norm', extract_json('.974_y'), flatten_array, dlme_strip, dlme_gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', extract_json('.974_y'), flatten_array, dlme_strip, dlme_gsub('/', '-'), parse_range, hijri_range
to_field 'cho_description', extract_json('.500_a'), flatten_array, dlme_strip, dlme_prepend('Binding: '), lang('en')
to_field 'cho_description', extract_json('.563_a'), flatten_array, dlme_strip, lang('en')
to_field 'cho_description', extract_json('.520_a'), flatten_array, dlme_strip, dlme_prepend('Collation: '), lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.300_a'), flatten_array, dlme_strip, lang('en')
to_field 'cho_extent', extract_json('.300_c'), flatten_array, dlme_strip, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.035_a'), flatten_array, dlme_strip
to_field 'cho_identifier', extract_json('.055_a'), flatten_array, dlme_strip
to_field 'cho_language', extract_json('.546_a'), flatten_array, dlme_split('and'), dlme_gsub('Text in', ''), dlme_gsub('In', ''), dlme_gsub('.', ''), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.546_a'), flatten_array, dlme_split('and'), dlme_gsub('Text in', ''), dlme_gsub('In', ''), dlme_gsub('.', ''), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.592_a'), flatten_array, dlme_strip, dlme_prepend('Current location: '), lang('en')
to_field 'cho_provenance', extract_json('.791_a'), flatten_array, dlme_strip, dlme_prepend('Current location: '), lang('en')
to_field 'cho_subject', extract_json('.650_a'), flatten_array, dlme_strip, lang('en')
to_field 'cho_subject', extract_json('.650_v'), flatten_array, dlme_strip, lang('en')
to_field 'cho_subject', extract_json('.655_a'), flatten_array, dlme_strip, lang('en')
to_field 'cho_subject', extract_json('.630_a'), flatten_array, dlme_strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.001'), flatten_array, dlme_strip, dlme_prepend('https://catalog.hathitrust.org/Record/')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.974_u'), flatten_array, at_index(0), dlme_strip, dlme_prepend('https://babel.hathitrust.org/cgi/imgsrv/cover?id='), dlme_append(';width=250')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

# Ignore
## 003
## 005
## 006
## 007
## 008
## 019_a
## 040_a
## 040_b
## 040_c
## 040_d
## 040_e
## 041_a
## 041_g
## 041_h
## 043_a
## 049_a
## 050_a
## 050_b
## 060_a
## 060_b
## 066_c
## 100_6
## 100_a
## 100_c
## 100_d
## 100_e
## 130_6
## 130_a
## 130_l
## 240_6
## 240_h
## 240_n
## 245_6
## 245_b
## 245_c
## 245_k
## 245_n
## 246_6
## 246_i
## 246_n
## 260_a
## 260_c
## 264_6
## 264_a
## 264_b
## 300_b
## 336_2
## 336_2
## 336_a
## 336_b
## 337_2
## 337_a
## 337_b
## 338_2
## 338_a
## 338_b
## 500_5
## 500_6
## 501_5
## 501_a
## 505_t
## 510_a
## 510_c
## 530_a
## 538_a
## 540_5
## 540_a
## 541_5
## 541_a
## 546_a
## 546_b
## 561_5
## 561_a
## 563_5
## 588_a
## 590_a
## 591_a
## 593_a
## 594_a
## 594_c
## 600_0
## 600_2
## 600_6
## 600_a
## 600_c
## 600_d
## 600_k
## 600_n
## 600_p
## 600_t
## 600_v
## 630_0
## 630_2
## 630_6
## 630_l
## 630_v
## 648_2
## 648_a
## 650_0
## 650_2
## 650_y
## 650_z
## 651_0
## 651_2
## 651_a
## 651_y
## 651_z
## 655_0
## 655_2
## 655_v
## 655_y
## 700_6
## 700_a
## 700_c
## 700_d
## 700_e
## 700_i
## 700_k
## 700_n
## 700_q
## 700_t
## 710_a
## 710_b
## 710_k
## 710_k
## 710_l
## 710_n
## 730_6
## 730_a
## 752_a
## 752_d
## 776_a
## 776_i
## 776_t
## 790_a
## 790_c
## 790_d
## 790_e
## 790_q
## 791_a
## 791_b
## 791_k
## 791_l
## 791_n
## 793_a
## 793_p
## 880_5
## 880_6
## 880_a
## 880_b
## 880_d
## 880_e
## 880_h
## 880_i
## 880_k
## 880_n
## 880_p
## 880_t
## 974_8
## 974_b
## 974_c
## 974_d
## 974_q
## 974_r
## 974_s
## 974_t
## 974_z
## CAT_a
## CAT_d
## CAT_l
## CID_a
## DAT_a
## DAT_b
## FMT_a
## HOL_0
## HOL_1
## HOL_8
## HOL_a
## HOL_b
## HOL_c
## HOL_p
## HOL_s
## HOL_z
## leader

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
  'dlme_collection',
  'agg_data_provider_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
