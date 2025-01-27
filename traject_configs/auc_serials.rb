# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/transformation'
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

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('auc-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('auc-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('auc-')

# File path
to_field 'dlme_source_file', path_to_file
to_field 'dlme_project', literal('dlme-serials')

# Cho Required
to_field 'id', extract_json('..id'), dlme_gsub('/manifest.json', ''), dlme_gsub('https://cdm15795.contentdm.oclc.org/iiif/', '')
to_field 'cho_title', extract_json('..title'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('..title-by-creator'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('..title'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('..title-english'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('..title-french'), flatten_array, lang('fr')
to_field 'cho_title', extract_json('..title-arabic'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('..title-arabic-العنوان'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('..title-inscribed'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_json('..title-transliteration'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')

# Cho Other
to_field 'cho_alternative', extract_json('..alternative-title'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_alternative', extract_json('..title-alternative'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_contributor', extract_json('..collector'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Collector: ', 'جامع: ')
to_field 'cho_contributor', extract_json('..compiler'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Compiler: ', 'مترجم: ')
to_field 'cho_contributor', extract_json('..contributor'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_contributor', extract_json('..scribe'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Scribe: ', 'الكاتب: ')
to_field 'cho_coverage', extract_json('..coverage'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_creator', extract_json('..architect'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Architect: ', 'مهندس معماري: ')
to_field 'cho_creator', extract_json('..artist'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Artist: ', 'فنان: ')
to_field 'cho_creator', extract_json('..author'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Author: ', 'مؤلف: ')
to_field 'cho_creator', extract_json('..creator'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_creator', extract_json('..creator-arabic'), flatten_array, lang('ar-Arab')
to_field 'cho_creator', extract_json('..creator-arabic-alternative'), flatten_array, lang('ar-Arab')
to_field 'cho_creator', extract_json('..creator-alternative'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_creator', extract_json('..creator-english'), flatten_array, lang('en')
to_field 'cho_creator', extract_json('..creator-english-alternative'), flatten_array, lang('en')
to_field 'cho_creator', extract_json('..creator-transliteration'), flatten_array, lang('en')
to_field 'cho_creator', extract_json('..photographer'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Photographer: ', 'مصور فوتوغرافي: ')
to_field 'cho_date', extract_json('..date'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_hijri', extract_json('..date'), flatten_array, auc_date_range, hijri_range
to_field 'cho_date_range_norm', extract_json('..date'), flatten_array, auc_date_range
to_field 'cho_date', extract_json('..date-built'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_hijri', extract_json('..date-built'), flatten_array, auc_date_range, hijri_range
to_field 'cho_date_range_norm', extract_json('..date-built'), flatten_array, auc_date_range
to_field 'cho_date', extract_json('..date-created'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_date_range_hijri', extract_json('..date-created'), flatten_array, auc_date_range, hijri_range
to_field 'cho_date_range_norm', extract_json('..date-created'), flatten_array, auc_date_range
to_field 'cho_dc_rights', extract_json('..license'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_dc_rights', extract_json('..access-rights'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_dc_rights', extract_json('..rights'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('..annotation'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Annotation: ', 'تعليق توضيحي: ')
to_field 'cho_description', extract_json('..architectural-detail'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Architectural detail: ', 'التفاصيل المعمارية: ')
to_field 'cho_description', extract_json('..architectural-detail-arabic'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Architectural detail: ', 'التفاصيل المعمارية: ')
to_field 'cho_description', extract_json('..architectural-detail-english'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Architectural detail: ', 'التفاصيل المعمارية: ')
to_field 'cho_description', extract_json('..dimensions-of-original'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Dimensions of original: ', 'أبعاد الأصل: ')
to_field 'cho_description', extract_json('..dimensions-of-printed-material'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Dimensions of print: ', 'تقنية: ')
to_field 'cho_description', extract_json('..description'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('..description-arabic'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('..description-english'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('..inscription'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Inscription: ', 'النقش: ')
to_field 'cho_description', extract_json('..notes'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Notes: ', 'ملحوظات: ')
to_field 'cho_description', extract_json('..material'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Material: ', 'مادة: ')
to_field 'cho_description', extract_json('..photo-term'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Photo type: ', 'نوع الصورة: ')
to_field 'cho_description', extract_json('..printed-material'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_description', extract_json('..scale'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Scale: ', 'حصة تموينية: ')
to_field 'cho_description', extract_json('..sheet-scale'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Scale: ', 'حصة تموينية: ')
to_field 'cho_description', extract_json('..style-period'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Style period: ', 'فترة النمط: ')
to_field 'cho_description', extract_json('..technique'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Technique: ', 'أبعاد الطباعة: ')
to_field 'cho_description', extract_json('..technical-details-of-original-drawing'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Technical details: ', 'تفاصيل تقنية: ')
to_field 'cho_description', extract_json('..technique-of-paper-drawing'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Technique: ', 'أبعاد الطباعة: ')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('..extent'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
# The line below seems to be adding many numbers in the UI with "Size: " prepended. Commenting it out for now.
# to_field 'cho_extent', extract_json('..size'), flatten_array, transform(&:to_s), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Size: ', 'مقاس: ')
to_field 'cho_extent', extract_json('..size-in-cm'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Size in cm: ', 'الحجم بالسم: ')
to_field 'cho_extent', extract_json('..size-h--x--w-cm'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Size in cm: ', 'الحجم بالسم: ')
to_field 'cho_extent', extract_json('..size-h-x-w-cm'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Size in cm: ', 'الحجم بالسم: ')
to_field 'cho_extent', extract_json('..extent-in-cm'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Size in cm: ', 'الحجم بالسم: ')
to_field 'cho_extent', extract_json('..measurements-h-x-w-in-cm-without-frame'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Measurements without frame (cm): ', 'القياسات بدون إطار (سم): ')
to_field 'cho_format', extract_json('..format'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_format', extract_json('..physical-format'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_has_type', literal('Serials'), lang('en')
to_field 'cho_has_type', literal('Serials'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('..call-number'), flatten_array
to_field 'cho_identifier', extract_json('..contentdm-number'), flatten_array
to_field 'cho_identifier', extract_json('..identifier'), flatten_array
to_field 'cho_identifier', extract_json('..object-identifier'), flatten_array
to_field 'cho_identifier', extract_json('..original-identifier'), flatten_array
to_field 'cho_is_part_of', extract_json('..collection'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_is_part_of', extract_json('..collection-name'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_is_part_of', extract_json('..digital-collection'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_is_part_of', extract_json('..relation'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_language', extract_json('..language'), flatten_array, dlme_split(';'), dlme_split(':'), dlme_split(','), dlme_split('/'), dlme_split(' & '), dlme_split(' and '), dlme_split(' , and '), dlme_gsub('\\r', ''), dlme_gsub('\\n', ''), dlme_gsub('\r', ''), dlme_gsub('\n', ''), dlme_gsub('.', ''), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('..language'), flatten_array, dlme_split(';'), dlme_split(':'), dlme_split(','), dlme_split('/'), dlme_split(' & '), dlme_split(' and '), dlme_split(' , and '), dlme_gsub('\\r', ''), dlme_gsub('\\n', ''), dlme_gsub('\r', ''), dlme_gsub('\n', ''), dlme_gsub('.', ''), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', extract_json('..languages'), flatten_array, dlme_split(';'), dlme_split(':'), dlme_split(','), dlme_split('/'), dlme_split(' & '), dlme_split(' and '), dlme_split(' , and '), dlme_gsub('\\r', ''), dlme_gsub('\\n', ''), dlme_gsub('\r', ''), dlme_gsub('\n', ''), dlme_gsub('.', ''), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('..languages'), flatten_array, dlme_split(';'), dlme_split(':'), dlme_split(','), dlme_split('/'), dlme_split(' & '), dlme_split(' and '), dlme_split(' , and '), dlme_gsub('\\r', ''), dlme_gsub('\\n', ''), dlme_gsub('\r', ''), dlme_gsub('\n', ''), dlme_gsub('.', ''), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_medium', extract_json('..medium'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_project_type', literal('issue'), lang('en')
to_field 'cho_provenance', extract_json('..provenance'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_provenance', extract_json('..source-donation-note'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_publisher', extract_json('..publisher'), flatten_array, lang('ar-Arab')
to_field 'cho_related', extract_json('..united-nations-record'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..coverage-spatialnote'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-country-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-country-english'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-english-name'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-english'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-getty-thesaurus-of-geographic-names-tgn'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-governorate-alternative'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-governorate-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-governorate-english'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-governorate-transliteration'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..location-governorate-arabic-alternative'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..site'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..site-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_spatial', extract_json('..site-english'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..keyword'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Keywords: ', 'الكلمات الرئيسية: ')
to_field 'cho_subject', extract_json('..keywords'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en'), intelligent_prepend('Keywords: ', 'الكلمات الرئيسية: ')
to_field 'cho_subject', extract_json('..subject'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..subject-aat'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..subject-english'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..subject-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..subject-lc'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..subject-lcsh'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
# subject-lcsh-arabic is not present in harvested data, presumabely because subject-lchs-arabic is present and its a typo. Leaving
# subject-lcsh-arabic for future proofing, becuaset they will eventually fix the error.
to_field 'cho_subject', extract_json('..subject-lcsh-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..subject-lchs-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..subject-tgm'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..topic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..topic-arabic'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_subject', extract_json('..topic-english'), flatten_array, dlme_split(';'), arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', extract_json('..genre'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', extract_json('..genre-aat'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', extract_json('..type'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_type', extract_json('..type-dcmi'), flatten_array, arabic_script_lang_or_default('ar-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [literal('To inquire about permissions or reproductions, contact the Rare Books and Special Collections Library, The American University in Cairo at +20.2.2615.3676 or rbscl-ref@aucegypt.edu.')],
    # 'wr_format' => [extract_json('..iiif_format'), flatten_array, at_index(0)],# null value causing error, comment until AUC fixes
    'wr_id' => [extract_json('..source'), flatten_array, at_index(1), dlme_split('href="'), at_index(1), dlme_split('">'), at_index(0)],
    'wr_is_referenced_by' => [extract_json('..id'), flatten_array, at_index(0)]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [literal('To inquire about permissions or reproductions, contact the Rare Books and Special Collections Library, The American University in Cairo at +20.2.2615.3676 or rbscl-ref@aucegypt.edu.')],
    'wr_format' => [extract_json('..iiif_format'), flatten_array, at_index(0)],
    'wr_id' => [extract_json('..resource'), flatten_array, at_index(0), dlme_gsub('/full/full/0/default.jpg', '/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [extract_json('..id'), flatten_array, at_index(0)]
  )
end
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

# Ignored Fields
## edition
## egyptian-national?
## gender
## link-to-catalogue
## relationship-to-auc
## subseries-english
## age
## plate-number
## profile
## acknowledgements
## published-in
## description-of-plate
## coordinated-longitude
## titles-new
## repository
## project-type
## series
## nationality
## source
## link-to-catalog
## name
## state-edition
## date-submitted
## source-donation
## acknowledgments
## occupation
## subseries-arabic
## coordinates-latitude
## substance
## contentdm-file-name
## patron
## context
## getty-aat
## date-beginning
## worktype
## worktype-of-printed-material

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
