# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/srw'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::SRW
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros

settings do
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

to_field 'agg_data_provider_collection', collection

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Cho Required
to_field 'id', extract_srw('dc:identifier'), strip

# Required per data agreement
to_field 'cho_provenance', literal('This document is part of BnF website \'Bibliothèques d\'Orient\' - http://heritage.bnf.fr/bibliothequesorient/'), lang('en')

# Cho Other
to_field 'cho_date', extract_srw('dc:date'), strip, lang('en')
to_field 'cho_date_range_norm', extract_srw('dc:date'), strip, parse_range
to_field 'cho_date_range_hijri', extract_srw('dc:date'), strip, parse_range, hijri_range
to_field 'cho_description', extract_srw('dc:description'), strip, lang('fr')
to_field 'cho_dc_rights', extract_srw('dc:rights[1]'), strip, lang('fr')
to_field 'cho_dc_rights', extract_srw('dc:rights[2]'), strip, lang('en')
to_field 'cho_format', extract_srw('dc:format'), strip, lang('fr')
to_field 'cho_language', extract_srw('dc:language'), first_only, strip, normalize_language, lang('en')
to_field 'cho_language', extract_srw('dc:language'), first_only, strip, normalize_language, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_relation', extract_srw('dc:relation'), strip, lang('fr')
to_field 'cho_source', extract_srw('dc:source'), strip, lang('fr')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_link, strip]
  )
end

to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_thumbnail, strip]
  )
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
  'cho_relation',
  'cho_source',
  'cho_spatial',
  'cho_temporal',
  'cho_title'
)
