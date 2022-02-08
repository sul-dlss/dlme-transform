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
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'agg_data_provider_collection', extract_json('.manifest'), gsub('https://cdm21044.contentdm.oclc.org/iiif/info/', ''), split('/'), first_only, transform(&:downcase), prepend('ssm-'), strip, translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', extract_json('.manifest'), gsub('https://cdm21044.contentdm.oclc.org/iiif/info/', ''), split('/'), first_only, transform(&:downcase), prepend('ssm-'), strip, translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', extract_json('.manifest')

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_json('.id'), strip, gsub('/manifest.json', ''), gsub('https://cdm21044.contentdm.oclc.org/iiif/info/', '')
to_field 'cho_title', extract_json('.title'), strip, lang('tr-Latn')

# Cho Other
to_field 'cho_alternative', extract_json('.title-alternative'), strip, lang('tr-Latn')
to_field 'cho_contributor', extract_json('.binder'), strip, prepend('Binder: '), lang('tr-Latn')
to_field 'cho_contributor', extract_json('.contributors'),
         strip, split('.'), lang('tr-Latn')
to_field 'cho_contributor', extract_json('.illuminator'),
         strip, prepend('Illuminator: '), lang('tr-Latn')
to_field 'cho_coverage', extract_json('.coverage'), strip, lang('tr-Latn')
to_field 'cho_coverage', extract_json('object-work-culture'), strip, lang('tr-Latn')
to_field 'cho_creator', extract_json('.artist'),
         strip, prepend('Artist: '), lang('tr-Latn')
to_field 'cho_creator', extract_json('.artist'),
         strip, prepend('Calligrapher: '), lang('tr-Latn')
to_field 'cho_creator', extract_json('.creator'),
         strip, split('.'), lang('tr-Latn')
to_field 'cho_date', extract_json('.date'), strip, lang('tr-Latn')
to_field 'cho_date_range_norm', extract_json('.date'), gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', extract_json('.date'), gsub('/', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('.rights'), strip, lang('tr-Latn')
to_field 'cho_dc_rights', extract_json('.copyright'), strip, lang('tr-Latn')
to_field 'cho_description', extract_json('.binding'), strip, prepend('Binding: '), lang('und-Latn')
to_field 'cho_description', extract_json('.conservation'), strip, prepend('Conservation: '), lang('und-Latn')
to_field 'cho_description', extract_json('.description'), strip, lang('tr-Latn')
to_field 'cho_description', extract_json('.illuminations'), strip, prepend('Illuminations: '), lang('und-Latn')
to_field 'cho_description', extract_json('.illustrations'), strip, prepend('Illustrations: '), lang('und-Latn')
to_field 'cho_description', extract_json('.inscriptions-marks'), strip, prepend('Inscriptions/Marks: '), lang('und-Latn')
to_field 'cho_description', extract_json('.materials-techniques'), strip, prepend('Materials/Techniques: '), lang('und-Latn')
to_field 'cho_description', extract_json('.measurements'), strip, prepend('Measurements: '), lang('und-Latn')
to_field 'cho_description', extract_json('.physical-appearance'), strip, prepend('Physical Appearance: '), lang('und-Latn')
to_field 'cho_description', extract_json('.script'), strip, prepend('Script: '), lang('und-Latn')
to_field 'cho_description', extract_json('.transcription'), strip, prepend('Translation: '), lang('und-Latn')
to_field 'cho_edm_type', extract_json('.type'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_json('.type'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('.format'), strip, lang('tr-Latn')
to_field 'cho_has_type', extract_json('.type'), normalize_has_type, lang('en')
to_field 'cho_has_type', extract_json('.type'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.identifier'), strip
to_field 'cho_language', extract_json('.language'), split(';'),
         strip, normalize_language, lang('en')
to_field 'cho_medium', extract_json('.format'), strip, lang('tr-Latn')
to_field 'cho_provenance', extract_json('.provenance'), strip, lang('tr-Latn')
to_field 'cho_publisher', extract_json('.publisher'), strip, lang('tr-Latn')
to_field 'cho_related', extract_json('see-also'), strip, lang('tr-Latn')
to_field 'cho_spatial', extract_json('creation-place'), strip, prepend('Creation place: '), lang('und-Latn')
to_field 'cho_subject', extract_json('.subject'), strip, lang('tr-Latn')
to_field 'cho_temporal', extract_json('object-work-culture'), strip, lang('tr-Latn')
to_field 'cho_type', extract_json('.type'), strip, arabic_script_lang_or_default('und-Latn', 'ar-Arab')

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
    'wr_format' => [extract_json('.iiif_format'), strip],
    'wr_id' => [extract_json('.id')],
    'wr_is_referenced_by' => [extract_json('.manifest'), strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_edm_rights' => [literal('InC-EDU: http://rightsstatements.org/page/InC-EDU/1.0/')],
    'wr_format' => [extract_json('.iiif_format'), strip],
    'wr_id' => [extract_json('.resource'), strip, gsub('/full/full/0/default.jpg', '/full/400,400/0/default.jpg')],
    'wr_is_referenced_by' => [extract_json('.manifest'), strip]
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
