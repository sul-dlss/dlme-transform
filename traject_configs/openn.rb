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
require 'macros/openn'
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
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::Openn
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

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('openn-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('openn-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('openn-')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_json('.id'), at_index(0), dlme_strip, dlme_gsub('https://libraries.aub.edu.lb/iiifservices/item/', ''), dlme_gsub('/manifest', ''), dlme_prepend('aub-')
to_field 'cho_title', extract_json('.title'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), default_multi_lang('Untitled', 'بدون عنوان')

# Cho Other
to_field 'cho_contributor', extract_json('.contributor'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn')
to_field 'cho_creator', extract_json('.author'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Author: ', 'مؤلف: ')
to_field 'cho_creator', extract_json('.scribe'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Scribe: ', 'الكاتب: ')
to_field 'cho_date', extract_json('.date'), flatten_array, dlme_strip, lang('en')
to_field 'cho_date_range_hijri', extract_json('.date'), flatten_array, dlme_strip, parse_range, hijri_range
to_field 'cho_date_range_norm', extract_json('.date'), flatten_array, dlme_strip, parse_range
to_field 'cho_dc_rights', extract_json('.licence'), flatten_array, dlme_strip, lang('en')
to_field 'cho_description', extract_json('.binding'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Binding: ', 'ملزم: ')
to_field 'cho_description', extract_json('.decoration_note'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Decoration note: ', 'ملاحظة الديكور: ')
to_field 'cho_description', extract_json('.foliation'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Foliation: ', 'ترقيم الأوراق: ')
to_field 'cho_description', extract_json('.layout'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Layout: ', 'تَخطِيط: ')
to_field 'cho_description', extract_json('.note'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Note: ', 'ملحوظة: ')
to_field 'cho_description', extract_json('.script_note'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Script note: ', 'ملاحظة البرنامج النصي: ')
to_field 'cho_description', extract_json('.summary'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Summary: ', 'ملخص: ')
to_field 'cho_description', extract_json('.watermark'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'und-Latn'), intelligent_prepend('Watermark: ', 'العلامة المائية:')
to_field 'cho_edm_type', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('aub-'), translation_map('has_type_from_collection'), translation_map('edm_type_from_has_type'), lang('en')
to_field 'cho_edm_type', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('aub-'), translation_map('has_type_from_collection'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.extent'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_has_type', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('aub-'), translation_map('has_type_from_collection'), lang('en')
to_field 'cho_has_type', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('aub-'), translation_map('has_type_from_collection'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.alternate_id'), flatten_array, dlme_strip
to_field 'cho_is_part_of', literal('OPenn Manuscripts of the Muslim World: https://openn.library.upenn.edu/html/muslimworld_contents.html'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_language', extract_json('.language'), flatten_array, dlme_split('and'),
         dlme_split(';'), dlme_split('/'), dlme_gsub('(', ''), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.language'), flatten_array, dlme_split('and'),
         dlme_split(';'), dlme_split('/'), dlme_gsub('(', ''), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.provenance'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_provenance', extract_json('.former_owner'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Former owner: ', 'المالك السابق: ')
to_field 'cho_provenance', extract_json('.donor'), flatten_array, dlme_strip, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Donor: ', 'الجهة المانحة: ')
to_field 'cho_publisher', extract_json('.publisher'), flatten_array, dlme_strip, lang('en')
to_field 'cho_spatial', extract_json('.origin_place'), flatten_array, dlme_strip, lang('en')
to_field 'cho_subject', extract_json('.subjects'), flatten_array, dlme_strip, dlme_prepend('LCSH: '), lang('en')
to_field 'cho_subject', extract_json('.form_genre'), flatten_array, dlme_strip, dlme_prepend('Form/genre: '), lang('en')
to_field 'cho_subject', extract_json('.keywords'), flatten_array, dlme_strip, dlme_prepend('Keywords: '), lang('en')

# Agg
to_field 'agg_data_provider', extract_json('.publisher'), dlme_default('Haverford College'), dlme_gsub('.', ''), dlme_gsub('Department of South Asian Art', 'Philadelphia Museum of Art'), lang('en')
to_field 'agg_data_provider', extract_json('.publisher'), dlme_default('Haverford College'), dlme_gsub('.', ''), dlme_gsub('Department of South Asian Art', 'Philadelphia Museum of Art'), translation_map('data_provider_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_country', extract_json('.publisher'), dlme_default('Haverford College'), dlme_gsub('.', ''), dlme_gsub('Department of South Asian Art', 'Philadelphia Museum of Art'), translation_map('data_provider_to_country'), lang('en')
to_field 'agg_data_provider_country', extract_json('.publisher'), dlme_default('Haverford College'), dlme_gsub('.', ''), dlme_gsub('Department of South Asian Art', 'Philadelphia Museum of Art'), translation_map('data_provider_to_country'), translation_map('country_en_to_ar'), lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.alternate_id'), flatten_array],
    'wr_id' => [extract_agg_shown_at('.harvest_url')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.licence'), flatten_array],
    'wr_id' => [extract_preview_url('.harvest_url', '.preview')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

# Ignored Fields
## repository
## harvest_url
## preview

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
