# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/csic'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/dlme_marc'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/timestamp'
require 'macros/version'
require 'traject/macros/marc21_semantics'
require 'traject/macros/marc_format_classifier'
require 'traject_plus'

extend Macros::Collection
extend Macros::Csic
extend Macros::DLME
extend Macros::DateParsing
extend Macros::DlmeMarc
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::Timestamp
extend Macros::Version
extend Traject::Macros::Marc21
extend Traject::Macros::Marc21Semantics
extend Traject::Macros::MarcFormats
extend TrajectPlus::Macros

settings do
  provide 'reader_class_name', 'MARC::XMLReader'
  provide 'marc_source.type', 'xml'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'dlme_collection', literal('csic'), translation_map('dlme_collection_from_provider_id'), lang('en')
to_field 'dlme_collection', literal('csic'), translation_map('dlme_collection_from_provider_id'), translation_map('dlme_collection_ar_from_en'), lang('ar-Arab')

# CHO Required
to_field 'id', extract_marc('001'), first_only
to_field 'cho_title', extract_marc('245ab', alternate_script: false), trim_punctuation, arabic_script_lang_or_default('ar-Arab', 'es')

# CHO Other
to_field 'cho_alternative', extract_marc('130a:240a:246ab', alternate_script: false), trim_punctuation, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_alternative', extract_marc('740a', alternate_script: false), trim_punctuation, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_contributor', extract_marc('700abce:710abcde:711acde:720ae', alternate_script: false), trim_punctuation, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_creator', extract_marc('100abc:110abcd:111acd', alternate_script: false), trim_punctuation, arabic_script_lang_or_default('ar-Arab', 'es')
to_field 'cho_date', extract_marc('260c'), lang('und-Latn')
to_field 'cho_date_range_norm', extract_marc('008[06-14]'), marc_date_range
to_field 'cho_date_range_hijri', extract_marc('008[06-14]'), marc_date_range, hijri_range
to_field 'cho_description', extract_marc('500a:505agrtu:520abcu', alternate_script: false), strip, lang('es')
to_field 'cho_description', extract_marc('563a', alternate_script: false), strip, lang('es')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_marc('300abcefg', alternate_script: false), trim_punctuation, lang('es')
to_field 'cho_format', marc_formats, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', oclcnum
to_field 'cho_is_part_of', extract_marc('440a:490a:800abcdt:400abcd:810abcdt:410abcd:811acdeft:411acdef:830adfgklmnoprst:760ast', alternate_script: false), lang('es')
to_field 'cho_language', extract_marc('008[35-37]:041a:041d'), normalize_language, lang('en')
to_field 'cho_language', extract_marc('008[35-37]:041a:041d'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_publisher', extract_marc('260b:264b', alternate_script: false), trim_punctuation, lang('en')
to_field 'cho_provenance', extract_marc('541a', alternate_script: false), trim_punctuation, lang('es')
to_field 'cho_spatial', marc_geo_facet, lang('en')
SIX00 = '600abcdefghjklmnopqrstuvxy'
SIX10 = '610abcdefghklmnoprstuvxy'
SIX11 = '611acdefghjklnpqstuvxy'
SIX30 = '630adefghklmnoprstvxy'
SIX5X = '650abcdegvxy:651aegvxy:653a:654abcevy'
SIXXX_SPEC = [SIX00, SIX10, SIX11, SIX30, SIX5X].join(':')
to_field 'cho_subject', extract_marc(SIXXX_SPEC, alternate_script: false), lang('es')
to_field 'cho_temporal', marc_era_facet, lang('en')
to_field 'cho_type', extract_marc('245h', alternate_script: false), trim_punctuation, lang('es')

# Agg Required
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [extract_marc('035a'), first_only, strip, prepend('http://aleph.csic.es/imagenes/mad01/0006_PMSC/thumb/'), append('.jpg')])
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

# Agg Additional
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [extract_marc('856u'), extract_preview])
end

# NOTE:  add the below to collection specific config
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
  'dlme_collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
