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

to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('ssm-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('ssm-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, dlme_split('/'), at_index(-2), dlme_gsub('_', '-'), dlme_prepend('ssm-')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_json('.id'), dlme_gsub('https://cdm21044.contentdm.oclc.org/iiif/', ''), dlme_gsub('/manifest.json', ''), dlme_gsub(':', '-'), transform(&:downcase)
to_field 'cho_title', extract_json('.başlık-title'), flatten_array, lang('tr-Latn')

# Cho Other
to_field 'cho_alternative', extract_json('.diğer-başlık-title-alternative'), flatten_array, lang('tr-Latn')
to_field 'cho_creator', extract_json('.sanatçı-artist'), flatten_array, dlme_prepend('Artist: '), lang('tr-Latn')
to_field 'cho_creator', extract_json('.sorumluluk-alanı-creator'), flatten_array, dlme_prepend('Artist: '), lang('tr-Latn')
to_field 'cho_contributor', extract_json('.hattat-calligrapher'), flatten_array, dlme_prepend('Calligrapher: '), lang('tr-Latn')
to_field 'cho_contributor', extract_json('.müzehhip-illuminator'), flatten_array, dlme_prepend('Illuminator: '), lang('tr-Latn')
to_field 'cho_contributor', extract_json('.tuğrakeş-contributors'), flatten_array, lang('tr-Latn')
to_field 'cho_contributor', extract_json('.usta-contributors'), flatten_array, lang('tr-Latn')
to_field 'cho_date', extract_json('.tarih-date'), flatten_array, lang('tr-Latn')
to_field 'cho_date_range_norm', extract_json('.tarih-date'), flatten_array, parse_range
to_field 'cho_date_range_hijri', extract_json('.tarih-date'), flatten_array, parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('.telif-hakkı-copyright'), flatten_array, lang('tr-Latn')
to_field 'cho_dc_rights', extract_json('.telif-hakkı-rights'), flatten_array, lang('tr-Latn')
to_field 'cho_description', extract_json('.açıklama-description'), flatten_array, lang('tr-Latn')
to_field 'cho_description', extract_json('.fiziksel-görünüm-physical-appearance'), flatten_array, dlme_prepend('Physical Appearance: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.kayıtlar-inscriptions/marks'), flatten_array, dlme_prepend('Inscriptions: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.ketebe-ve-zehebe-kaydı-inscriptions'), flatten_array, dlme_prepend('Inscriptions: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.konservasyon-conservation'), flatten_array, dlme_prepend('Conservation: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.cilt-binding'), flatten_array, dlme_prepend('Binding: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.malzemeler-materials'), flatten_array, dlme_prepend('Materials: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.mühürler-ve-diğer-kayıtlar-inscriptions'), flatten_array, dlme_prepend('Inscriptions: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.tezhipler-illuminations'), flatten_array, dlme_prepend('Illuminations: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.teknik-materials/techniques'), flatten_array, dlme_prepend('Materials/Techniques: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.transkripsiyon-transcription'), flatten_array, dlme_prepend('Transcription: '), lang('tr-Latn')
to_field 'cho_description', extract_json('.yazı-cinsi-script'), flatten_array, dlme_prepend('Script: '), lang('tr-Latn')
to_field 'cho_edm_type', extract_json('.tür-type'), flatten_array, normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.tür-type'), flatten_array, normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.boyutlar-measurements'), flatten_array, dlme_prepend('Measurements: '), lang('en')
to_field 'cho_format', extract_json('.format'), flatten_array, dlme_strip, lang('tr-Latn')
to_field 'cho_has_type', extract_json('.tür-type'), flatten_array, normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.tür-type'), flatten_array, normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.envanter-numarası-accession-number'), flatten_array, dlme_strip
to_field 'cho_identifier', extract_json('.envanter-numarası-identifier'), flatten_array, dlme_strip
to_field 'cho_language', extract_json('.dil-language'), flatten_array, dlme_split(';'), dlme_strip, normalize_language, lang('en')
to_field 'cho_publisher', extract_json('.yayıncı-publisher'), flatten_array, lang('en')
to_field 'cho_relation', extract_json('.ayrıca-bakınız-see-also'), flatten_array, lang('en')
to_field 'cho_temporal', extract_json('.dönem-object/work-culture'), flatten_array, lang('tr-Latn')
to_field 'cho_type', extract_json('.tür-type'), flatten_array, lang('tr-Latn')

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
    'wr_format' => [extract_json('.iiif_format'), flatten_array, at_index(0), dlme_strip],
    'wr_id' => [extract_json('.id'), flatten_array, dlme_strip, dlme_gsub('https://cdm21044.contentdm.oclc.org/iiif/', ''), dlme_gsub('/manifest.json', ''), dlme_gsub(':', '/id/'), dlme_prepend('https://cdm21044.contentdm.oclc.org/cdm/ref/collection/')],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_format' => [extract_json('.iiif_format'), flatten_array, at_index(0), dlme_strip],
    'wr_id' => [extract_json('.resource'), flatten_array, at_index(0), dlme_strip, dlme_gsub('/full/full/0/default.jpg', '/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [extract_json('.id'), flatten_array, dlme_strip]
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
