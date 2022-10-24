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

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('ssm-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('ssm-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('ssm-')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', column('id'), gsub('https://cdm21044.contentdm.oclc.org/iiif/2/', ''), gsub('/manifest.json', ''), gsub(':', '-'), transform(&:downcase)
to_field 'cho_title', column('başlık-title'), parse_csv, lang('tr-Latn')

# Cho Other
to_field 'cho_alternative', column('diğer-başlık-title-alternative'), parse_csv, lang('tr-Latn')
to_field 'cho_creator', column('sanatçı-artist'), parse_csv, prepend('Artist: '), lang('tr-Latn')
to_field 'cho_creator', column('sorumluluk-alanı-creator'), parse_csv, prepend('Artist: '), lang('tr-Latn')
to_field 'cho_contributor', column('hattat-calligrapher'), parse_csv, prepend('Calligrapher: '), lang('tr-Latn')
to_field 'cho_contributor', column('müzehhip-illuminator'), parse_csv, prepend('Illuminator: '), lang('tr-Latn')
to_field 'cho_contributor', column('tuğrakeş-contributors'), parse_csv, lang('tr-Latn')
to_field 'cho_contributor', column('usta-contributors'), parse_csv, lang('tr-Latn')
to_field 'cho_date', column('tarih-date'), parse_csv, lang('tr-Latn')
to_field 'cho_date_range_norm', column('tarih-date'), parse_range
to_field 'cho_date_range_hijri', column('tarih-date'), parse_range, hijri_range
to_field 'cho_dc_rights', column('telif-hakkı-copyright'), parse_csv, lang('tr-Latn')
to_field 'cho_dc_rights', column('telif-hakkı-rights'), parse_csv, lang('tr-Latn')
to_field 'cho_description', column('açıklama-description'), parse_csv, lang('tr-Latn')
to_field 'cho_description', column('fiziksel-görünüm-physical-appearance'), parse_csv, prepend('Physical Appearance: '), lang('tr-Latn')
to_field 'cho_description', column('kayıtlar-inscriptions/marks'), parse_csv, prepend('Inscriptions: '), lang('tr-Latn')
to_field 'cho_description', column('ketebe-ve-zehebe-kaydı-inscriptions'), parse_csv, prepend('Inscriptions: '), lang('tr-Latn')
to_field 'cho_description', column('konservasyon-conservation'), parse_csv, prepend('Conservation: '), lang('tr-Latn')
to_field 'cho_description', column('cilt-binding'), parse_csv, prepend('Binding: '), lang('tr-Latn')
to_field 'cho_description', column('malzemeler-materials'), parse_csv, prepend('Materials: '), lang('tr-Latn')
to_field 'cho_description', column('mühürler-ve-diğer-kayıtlar-inscriptions'), parse_csv, prepend('Inscriptions: '), lang('tr-Latn')
to_field 'cho_description', column('tezhipler-illuminations'), parse_csv, prepend('Illuminations: '), lang('tr-Latn')
to_field 'cho_description', column('teknik-materials/techniques'), parse_csv, prepend('Materials/Techniques: '), lang('tr-Latn')
to_field 'cho_description', column('transkripsiyon-transcription'), parse_csv, prepend('Transcription: '), lang('tr-Latn')
to_field 'cho_description', column('yazı-cinsi-script'), parse_csv, prepend('Script: '), lang('tr-Latn')
to_field 'cho_edm_type', column('tür-type'), parse_csv, normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', column('tür-type'), parse_csv, normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', column('boyutlar-measurements'), parse_csv, prepend('Measurements: '), lang('en')
to_field 'cho_format', column('format'), parse_csv, strip, lang('tr-Latn')
to_field 'cho_has_type', column('tür-type'), parse_csv, normalize_has_type, lang('en')
to_field 'cho_has_type', column('tür-type'), parse_csv, normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', column('envanter-numarası-accession-number'), parse_csv, strip
to_field 'cho_identifier', column('envanter-numarası-identifier'), parse_csv, strip
to_field 'cho_language', column('dil-language'), parse_csv, split(';'), strip, normalize_language, lang('en')
to_field 'cho_publisher', column('yayıncı-publisher'), parse_csv, lang('en')
to_field 'cho_related', column('ayrıca-bakınız-see-also'), parse_csv, lang('en')
to_field 'cho_temporal', column('dönem-object/work-culture'), parse_csv, lang('tr-Latn')
to_field 'cho_type', column('tür-type'), parse_csv, lang('tr-Latn')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'agg_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_format' => [column('iiif_format'), parse_csv, strip],
    'wr_id' => [column('id'), parse_csv, strip, gsub('https://cdm21044.contentdm.oclc.org/iiif/2/emrigan:', ''), gsub('/manifest.json', ''), prepend('ttp://cdm21044.contentdm.oclc.org/cdm/ref/collection/emirgan/id/')],
    'wr_is_referenced_by' => [column('id'), parse_csv, strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_format' => [column('iiif_format'), parse_csv, strip],
    'wr_id' => [column('resource'), parse_csv, at_index(0), strip, gsub('/full/full/0/default.jpg', '/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [column('id'), parse_csv, strip]
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
