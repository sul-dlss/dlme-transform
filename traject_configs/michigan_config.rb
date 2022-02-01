# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/dlme_marc'
require 'macros/each_record'
require 'macros/normalize_language'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'
require 'traject/macros/marc21_semantics'
require 'traject/macros/marc_format_classifier'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::DlmeMarc
extend Macros::EachRecord
extend Macros::NormalizeLanguage
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::Version
extend Traject::Macros::Marc21
extend Traject::Macros::Marc21Semantics
extend Traject::Macros::MarcFormats
extend TrajectPlus::Macros

# NOTE: most of the fields are populated via marc_config

settings do
  provide 'reader_class_name', 'MARC::XMLReader'
  provide 'marc_source.type', 'xml'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# # Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'dlme_collection', literal('michigan'), translation_map('dlme_collection_from_provider_id'), lang('en')
to_field 'dlme_collection', literal('michigan'), translation_map('dlme_collection_from_provider_id'), translation_map('dlme_collection_ar_from_en'), lang('ar-Arab')
to_field 'dlme_collection_id', literal('michigan')

# File path
to_field 'dlme_source_file', path_to_file

# CHO Required
to_field 'id', extract_marc('001'), first_only
to_field 'cho_title', extract_marc('245ab', alternate_script: false), trim_punctuation, lang('und-Latn')
to_field 'cho_title', extract_marc('245ab', alternate_script: :only), trim_punctuation, lang('und-Arab')

# Cho Additional
to_field 'cho_alternative', extract_marc('240a:246ab', alternate_script: false), trim_punctuation, lang('und-Latn')
to_field 'cho_alternative', extract_marc('240a:246ab', alternate_script: :only), trim_punctuation, lang('und-Arab')
to_field 'cho_contributor', extract_marc('700abce:710abcde:711acde:720ae', alternate_script: false), trim_punctuation, lang('und-Latn')
to_field 'cho_contributor', extract_marc('700abce:710abcde:711acde:720ae', alternate_script: :only), trim_punctuation, lang('und-Arab')
to_field 'cho_creator', extract_marc('100abc:110abcd:111acd', alternate_script: false), trim_punctuation, lang('und-Latn')
to_field 'cho_creator', extract_marc('100abc:110abcd:111acd', alternate_script: :only), trim_punctuation, lang('und-Arab')
to_field 'cho_date', extract_marc('260c'), lang('en')
to_field 'cho_date_range_norm', extract_marc('008[06-14]'), marc_date_range
to_field 'cho_date_range_hijri', extract_marc('008[06-14]'), marc_date_range, hijri_range
to_field 'cho_dc_rights', literal('Public Domain'), lang('en')
to_field 'cho_description', extract_marc('500a:505agrtu:520abcu', alternate_script: false), strip, gsub('Special Collections Library,', 'Special Collections Research Center'), lang('en')
to_field 'cho_description', extract_marc('500a:505agrtu:520abcu', alternate_script: :only), strip, lang('und-Arab')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_marc('300abcefg', alternate_script: false), trim_punctuation, lang('en')
to_field 'cho_format', marc_formats, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', oclcnum, prepend('OCLC: ')
to_field 'cho_language', extract_marc('008[35-37]:041a:041d'), normalize_language, lang('en')
to_field 'cho_language', extract_marc('008[35-37]:041a:041d'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_same_as', extract_marc('001'), strip, prepend('https://search.lib.umich.edu/catalog/record/')
to_field 'cho_spatial', marc_geo_facet, filter_data_errors('Ann Arbor (Michigan)', 'Michigan'), lang('en')
SIX00 = '600abcdefghjklmnopqrstuvxy'
SIX10 = '610abcdefghklmnoprstuvxy'
SIX11 = '611acdefghjklnpqstuvxy'
SIX30 = '630adefghklmnoprstvxy'
SIX5X = '650abcdegvxy:651aegvxy:653a:654abcevy'
SIXXX_SPEC = [SIX00, SIX10, SIX11, SIX30, SIX5X].join(':')
to_field 'cho_subject', extract_marc(SIXXX_SPEC, alternate_script: false), lang('en')
to_field 'cho_subject', extract_marc(SIXXX_SPEC, alternate_script: :only), lang('ar-Arab')
to_field 'cho_temporal', marc_era_facet, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_marc('001'),
                strip,
                prepend('https://catalog.hathitrust.org/Record/')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_marc('974u'),
                strip,
                prepend('https://babel.hathitrust.org/cgi/imgsrv/image?id='),
                append(';seq=7;size=50;rotation=0')]
  )
end
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
  'cho_has_type',
  'cho_has_part',
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
  'dlme_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
