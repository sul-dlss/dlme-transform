# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
require 'macros/iiif'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::FieldExtraction
extend Macros::IIIF
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
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

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('openiti'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('openiti'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(3), gsub('_', '-'), prepend('openiti')

# CHO Required
to_field 'id', extract_json('.version_uri')
to_field 'cho_title', extract_json('..title_lat'), flatten_array, default('Untitled'), lang('en')
to_field 'cho_title', extract_json('..title_ar'), flatten_array, default('بدون عنوان'), lang('ar-Arab')

# CHO Other
to_field 'cho_creator', extract_json('..author_ar'), flatten_array, lang('ar-Arab')
to_field 'cho_creator', extract_json('..author_lat'), flatten_array, lang('en')
to_field 'cho_date', extract_json_from_context('..date'), flatten_array, append(' AH'), lang('ar-Arab')
to_field 'cho_date', extract_json_from_context('.date'), append('هـ '), lang('en')
to_field 'cho_date_range_hijri', extract_json_from_context('.date'), parse_range
to_field 'cho_dc_rights', literal('المجال العام'), flatten_array, lang('ar-Arab')
to_field 'cho_dc_rights', literal('Public Domain'), flatten_array, lang('en')
to_field 'cho_description', literal('  نص يمكن قراءته آليًا وبيانات إعادة استخدام النص (من إصدار OpenITI 2023.1.8).'), lang('ar-Arab')
to_field 'cho_description', literal('Machine-readable text and text reuse datasets (from OpenITI release 2023.1.8).'), lang('en')
to_field 'cho_description', extract_json('..text_url'), flatten_array, prepend('نص يمكن قراءته آليًا: '), lang('ar-Arab')
to_field 'cho_description', extract_json('..text_url'), flatten_array, prepend('Machine-readable text: '), lang('en')
to_field 'cho_description', literal('  توثق مجموعات بيانات إعادة استخدام النص KITAB (https://kitab-project.org/data#passim-text-reuse-data-sets) التداخل بين النص الحالي والنصوص الأخرى في مجموعة مبادرة النصوص الإسلامية المفتوحة OpenITI.
'), lang('ar-Arab')
to_field 'cho_description', literal(' The KITAB text reuse datasets (https://kitab-project.org/data#passim-text-reuse-data-sets)
  document the overlap between the present work and other texts in the Open Islamicate Texts Initiative corpus.'), lang('en')
to_field 'cho_description', extract_json('..one2all_data_url'), flatten_array, prepend('  مجموعة البيانات التي توثق التداخل بين النص الحالي ومجموعة OpenITI بأكملها:
 '), lang('ar-Arab')
to_field 'cho_description', extract_json('..one2all_data_url'), flatten_array, prepend('Dataset documenting the overlap between the present text and the entire OpenITI corpus: '), lang('en')
to_field 'cho_description', extract_json('..one2all_stats_url'), flatten_array, prepend('الإحصائيات حول التداخل بين النص الحالي وجميع النصوص الأخرى في مجموعة OpenITI: '), lang('ar-Arab')
to_field 'cho_description', extract_json('..one2all_stats_url'), flatten_array, prepend('Statistics on the overlap between the present text and all other texts in the OpenITI corpus: '), lang('en')
to_field 'cho_description', extract_json('..one2all_vis_url'), flatten_array, prepend('التمثيل البصري للتداخل بين النص الحالي ومجموعة OpenITI بأكملها: '), lang('ar-Arab')
to_field 'cho_description', extract_json('..one2all_vis_url'), flatten_array, prepend('Visualization of the overlap between the present text and the entire OpenITI corpus: '), lang('en')
to_field 'cho_description', extract_json('..pairwise_data_url'), flatten_array, prepend(' مجموعات البيانات التي توثق التداخل بين النص الحالي ونص واحد آخر ("مقارنة زوجية"): '), lang('ar-Arab')
to_field 'cho_description', extract_json('..pairwise_data_url'), flatten_array, prepend('Datasets documenting the overlap between the present text and a single other text (“pairwise”): '), lang('en')
to_field 'cho_description', literal('  للحصول على إرشادات حول تحميل كافة بيانات KITAB وOpenITI دفعة واحدة، راجع https://kitab-project.org/data/download.'), lang('ar-Arab')
to_field 'cho_description', literal('For instructions on batch downloading all of the KITAB and OpenITI data, see
  https://kitab-projec.org/data/download'), lang('en')
to_field 'cho_description', extract_json('..ouncorrected_ocr_ar'), flatten_array, lang('ar-Arab')
to_field 'cho_description', extract_json('..uncorrected_ocr_en'), flatten_array, lang('en')
to_field 'cho_edm_type', literal('Dataset'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_edm_type', literal('Dataset'), lang('en')
to_field 'cho_has_type', literal('Text Reuse Data'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Text Reuse Data'), lang('en')
to_field 'cho_has_type', literal('Machine-Readable Text'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Machine-Readable Text'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_edm_rights', literal('https://creativecommons.org/share-your-work/public-domain/cc0/')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.one2all_vis_url')],
                                  'wr_dc_rights' => [literal('Public Domain')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [literal('https://live.staticflickr.com/65535/53517109670_5ea39337d3.jpg')],
                                  'wr_dc_rights' => [literal('Public Domain')])
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
