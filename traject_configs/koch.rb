# frozen_string_literal: true

require 'dlme_debug_writer'
require 'dlme_json_resource_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/timestamp'
require 'macros/transformation'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::Timestamp
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

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('koch-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('koch-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(2), dlme_gsub('_', '-'), dlme_prepend('koch-')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_json('.id'), flatten_array, dlme_strip, dlme_gsub('/manifest.json', ''), dlme_gsub('https://cdm21054.contentdm.oclc.org/iiif/', '')
to_field 'cho_title', extract_json('.başlık--title'), flatten_array, dlme_split(';'), dlme_strip, dlme_gsub('\\r\\n', ''), dlme_gsub('[', ''), dlme_gsub(']', ''), lang('tr-Latn')
to_field 'cho_title', extract_json('.başlık,-arap-alfabesiyle--title,-arabic-script'), flatten_array, dlme_split(';'), dlme_strip, dlme_gsub('\\r\\n', ''), dlme_gsub('[', ''), dlme_gsub(']', ''), lang('ar-Arab')

# Cho Other
to_field 'cho_contributor', extract_json('.müstensih--copyist'), flatten_array, dlme_split(';'), dlme_strip, dlme_prepend('Copyist: '), dlme_gsub('\\r\\n', ''), lang('tr-Latn')
to_field 'cho_creator', extract_json('.yazar--author'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), lang('tr-Latn')
to_field 'cho_creator', extract_json('.müellif,-arap-alfabesiyle--author,-arabic-script'), flatten_array, dlme_split(';'), dlme_strip, dlme_gsub('\\r\\n', ''), arabic_script_lang_or_default('ar-Arab', 'tr-Latn')
to_field 'cho_date', extract_json('.tarih-miladi--date-gregorian'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), lang('en')
# to_field 'cho_date_range_hijri', extract_json('.tarih-miladi--date-gregorian'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), auc_date_range, hijri_range
# to_field 'cho_date_range_norm', extract_json('.tarih-miladi--date-gregorian'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), auc_date_range
to_field 'cho_dc_rights', extract_json('.telif-hakkı-ve-kullanım--copyright-and-usage'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_gsub('[', ''), dlme_gsub(']', ''), lang('tr-Latn')
to_field 'cho_description', extract_json('.ciltleme-ve-tezhip-özellikleri--binding-and-script-features'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Binding and script features: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.fiziksel-tanımlama--physical-description'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Physical description: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.i̇çerik--content'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Contents: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.kağıt-türü--paper-type'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Paper type: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.kaligrafi-stili--calligraphic-style'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Calligraphic style: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.mürekkep-rengi--ink-color'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Ink color: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.notlar--notes'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Notes: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.yazının-tanımlaması--description-of-script'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Description of script: '), lang('tr-Latn')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('format--format'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.bib.-no.--call-no.'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', '')
to_field 'cho_identifier', extract_json('.yazma-no.---volüm-no.--ms.-no.---item-no.'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Manuscript item number: ')
to_field 'cho_is_part_of', extract_json('.dijital-koleksiyon--digital-collection'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), lang('en')
to_field 'cho_language', extract_json('.dil--language'), flatten_array, dlme_split(';'), dlme_strip, dlme_gsub('\\r\\n', ''), normalize_language, lang('en')
to_field 'cho_language', extract_json('.dil--language'), flatten_array, dlme_split(';'), dlme_strip, dlme_gsub('\\r\\n', ''), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.bağışçı--donator'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), dlme_prepend('Donator: '), lang('tr-Latn')
to_field 'cho_subject', extract_json('.konu--subject'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), lang('en')
to_field 'cho_subject', extract_json('.konu-başlıkları-tr--subject-headings-tr'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), lang('tr-Latn')
to_field 'cho_type', extract_json('.materyal-türü--material-type'), flatten_array, dlme_strip, dlme_gsub('\\r\\n', ''), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.telif-hakkı-ve-kullanım--copyright-and-usage'), flatten_array, at_index(0), strip],
    'wr_format' => [extract_json('.iiif_format'), flatten_array, at_index(0)],
    'wr_id' => [extract_json('.source'), flatten_array, at_index(0), dlme_split('<a href="'), at_index(-1), dlme_split('">'), at_index(0)],
    'wr_is_referenced_by' => [extract_json('.id')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_json('.telif-hakkı-ve-kullanım--copyright-and-usage'), flatten_array, at_index(0), strip],
    'wr_format' => [extract_json('.iiif_format'), flatten_array, at_index(0)],
    'wr_id' => [extract_json('.resource'), flatten_array, at_index(0), dlme_gsub('/full/full/0/default.jpg', '/full/400,400/9/default.jpg')],
    'wr_is_referenced_by' => [extract_json('.id')]
  )
end
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider_collection',
  'agg_data_provider_country',
  'agg_data_provider',
  'agg_provider_country',
  'agg_provider',
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
