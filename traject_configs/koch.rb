# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
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
extend Macros::Csv
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
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
extend TrajectPlus::Macros::Csv

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
end
# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('koch-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('koch-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('koch-')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', column('id'), parse_csv, strip, gsub('/manifest.json', ''), gsub('https://cdm21054.contentdm.oclc.org/iiif/', '')
# Don't parse_csv on title; the combination of quotation marks and commas is resulting in unexpected behavior
to_field 'cho_title', column('başlık-/-title'), split(';'), strip, squish, gsub('\\r\\n', ''), gsub('[', ''), gsub(']', ''), lang('tr-Latn')
to_field 'cho_title', column('başlık,-arap-alfabesiyle-/-title,-arabic-script'), split(';'), strip, squish, gsub('\\r\\n', ''), gsub('[', ''), gsub(']', ''), lang('ar-Arab')

# Cho Other
to_field 'cho_contributor', column('müstensih-/-copyist'), parse_csv, split(';'), strip, squish, prepend('Copyist: '), gsub('\\r\\n', ''), lang('tr-Latn')
to_field 'cho_creator', column('yazar-/-author'), parse_csv, strip, squish, gsub('\\r\\n', ''), lang('tr-Latn')
to_field 'cho_creator', column('müellif,-arap-alfabesiyle-/-author,-arabic-script'), parse_csv, split(';'), strip, squish, gsub('\\r\\n', ''), arabic_script_lang_or_default('ar-Arab', 'tr-Latn')
to_field 'cho_date', column('tarih-miladi-/-date-gregorian'), parse_csv, strip, squish, gsub('\\r\\n', ''), lang('en')
to_field 'cho_date_range_hijri', column('tarih-miladi-/-date-gregorian'), parse_csv, strip, gsub('\\r\\n', ''), auc_date_range, hijri_range
to_field 'cho_date_range_norm', column('tarih-miladi-/-date-gregorian'), parse_csv, strip, gsub('\\r\\n', ''), auc_date_range
to_field 'cho_dc_rights', column('telif-hakkı-ve-kullanım-/-copyright-and-usage'), strip, squish, gsub('\\r\\n', ''), gsub('[', ''), gsub(']', ''), lang('tr-Latn')
to_field 'cho_description', column('ciltleme-ve-tezhip-özellikleri-/-binding-and-script-features'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Binding and script features: '), lang('tr-Latn')
to_field 'cho_description', column('fiziksel-tanımlama-/-physical-description'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Physical description: '), lang('tr-Latn')
to_field 'cho_description', column('i̇çerik-/-content'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Contents: '), lang('tr-Latn')
to_field 'cho_description', column('kağıt-türü-/-paper-type'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Paper type: '), lang('tr-Latn')
to_field 'cho_description', column('kaligrafi-stili-/-calligraphic-style'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Calligraphic style: '), lang('tr-Latn')
to_field 'cho_description', column('mürekkep-rengi-/-ink-color'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Ink color: '), lang('tr-Latn')
to_field 'cho_description', column('notlar-/-notes'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Notes: '), lang('tr-Latn')
to_field 'cho_description', column('yazının-tanımlaması-/-description-of-script'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Description of script: '), lang('tr-Latn')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', column('format-/-format'), parse_csv, strip, squish, gsub('\\r\\n', ''), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('bib.-no.-/-call-no.'), parse_csv, strip, squish, gsub('\\r\\n', '')
to_field 'cho_identifier', column('yazma-no.---volüm-no.-/-ms.-no.---item-no.'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Manuscript item number: ')
to_field 'cho_is_part_of', column('dijital-koleksiyon-/-digital-collection'), parse_csv, strip, squish, gsub('\\r\\n', ''), lang('en')
to_field 'cho_language', column('dil-/-language'), parse_csv, split(';'), strip, squish, gsub('\\r\\n', ''), normalize_language, lang('en')
to_field 'cho_language', column('dil-/-language'), parse_csv, split(';'), strip, squish, gsub('\\r\\n', ''), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_provenance', column('bağışçı-/-donator'), parse_csv, strip, squish, gsub('\\r\\n', ''), prepend('Donator: '), lang('tr-Latn')
to_field 'cho_subject', column('konu-/-subject'), parse_csv, strip, squish, gsub('\\r\\n', ''), lang('en')
to_field 'cho_subject', column('konu-başlıkları-tr-/-subject-headings-tr'), parse_csv, strip, squish, gsub('\\r\\n', ''), lang('tr-Latn')
to_field 'cho_type', column('materyal-türü-/-material-type'), parse_csv, strip, squish, gsub('\\r\\n', ''), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [column('telif-hakkı-ve-kullanım-/-copyright-and-usage'), parse_csv, at_index(0), strip],
    'wr_format' => [column('iiif_format'), parse_csv, at_index(0)],
    'wr_id' => [column('source'), parse_csv, at_index(0), split('<a href="'), at_index(-1), split('">'), at_index(0)],
    'wr_is_referenced_by' => [column('id')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [column('telif-hakkı-ve-kullanım-/-copyright-and-usage'), parse_csv, at_index(0), strip],
    'wr_format' => [column('iiif_format'), parse_csv, at_index(0)],
    'wr_id' => [column('resource'), parse_csv, at_index(0), gsub('/full/full/0/default.jpg', '/full/400,400/9/default.jpg')],
    'wr_is_referenced_by' => [column('id')]
  )
end
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

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
