# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/cambridge'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_language'
require 'macros/path_to_file'
require 'macros/tei'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::Cambridge
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::NormalizeLanguage
extend Macros::PathToFile
extend Macros::Tei
extend Macros::Timestamp
extend Macros::TitleExtraction
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Tei
extend TrajectPlus::Macros::Xml

# Shortcut variables
MS_DESC = '//teiHeader/fileDesc/sourceDesc/msDescription'

settings do
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# File path
to_field 'dlme_source_file', path_to_file

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

to_field 'dlme_collection', literal('vatican'), translation_map('dlme_collection_from_provider_id'), lang('en')
to_field 'dlme_collection', literal('vatican'), translation_map('dlme_collection_from_provider_id'), translation_map('dlme_collection_ar_from_en'), lang('ar-Arab')
to_field 'dlme_collection_id', literal('vatican')

# Cho Required
to_field 'id', extract_tei("#{MS_DESC}/msIdentifier/idno")
to_field 'cho_title', xpath_title_or_desc('//fileDesc/titleStmt/title', "#{MS_DESC}/msPart/msContents/overview"), lang('und-Latn'), default('Untitled', 'بدون عنوان')

# Cho other
to_field 'cho_creator', extract_tei('//fileDesc/titleStmt/author/alias/authorityAuthor'), strip, lang('en')
to_field 'cho_date', extract_tei('//fileDesc/publicationStmt/date'), strip, lang('en')
to_field 'cho_date_range_norm', extract_tei('//fileDesc/publicationStmt/date'), strip, parse_range
to_field 'cho_date_range_hijri', extract_tei('//fileDesc/publicationStmt/date'), strip, parse_range, hijri_range
to_field 'cho_dc_rights', literal('Images Copyright Biblioteca Apostolica Vaticana'), lang('en')
to_field 'cho_description', extract_tei("#{MS_DESC}/msPart/msContents/overview"), strip, lang('en')
to_field 'cho_edm_type', literal('Text'), strip, lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), strip, lang('ar-Arab')
to_field 'cho_has_type', literal('Manuscripts'), strip, lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), strip, lang('ar-Arab')
to_field 'cho_language', literal('Arabic'), lang('en')
to_field 'cho_language', literal('Arabic'), translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_spatial', extract_tei('//fileDesc/publicationStmt/pubPlace'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_tei("#{MS_DESC}/msIdentifier/idno/@uriSYS")],
                                  'wr_is_referenced_by' => [extract_tei("#{MS_DESC}/msIdentifier/idno"), prepend('https://digi.vatlib.it/iiif/MSS_'), append('/manifest.json')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_tei("#{MS_DESC}/msIdentifier/idno"), prepend('https://digi.vatlib.it/pub/digit/MSS_'), append('/cover/cover.jpg')],
                                  'wr_is_referenced_by' => [extract_tei("#{MS_DESC}/msIdentifier/idno"), prepend('https://digi.vatlib.it/iiif/MSS_'), append('/manifest.json')])
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
  'dlme-collection'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
