# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'macros/dlme'
require 'macros/date_parsing'
require 'macros/srw'
require 'macros/post_process'

extend Macros::PostProcess
extend Macros::DLME
extend Macros::DateParsing
extend TrajectPlus::Macros
extend Macros::SRW

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Cho Required
to_field 'id', extract_srw('dc:identifier'), strip
to_field 'cho_title', extract_srw('dc:title'), strip

# Required per data agreement
to_field 'cho_provenance', literal('This document is part of BnF website \'Bibliothèques d\'Orient\' - http://heritage.bnf.fr/bibliothequesorient/')

# Cho Other
to_field 'cho_date', extract_srw('dc:date'), strip
to_field 'cho_date_range_norm', extract_srw('dc:date'), strip, parse_range
to_field 'cho_date_range_hijri', extract_srw('dc:date'), strip, parse_range, hijri_range
to_field 'cho_description', extract_srw('dc:description'), strip
to_field 'cho_dc_rights', extract_srw('dc:rights'), strip
to_field 'cho_format', extract_srw('dc:format'), strip
to_field 'cho_publisher', extract_srw('dc:publisher'), strip
to_field 'cho_relation', extract_srw('dc:relation'), strip
to_field 'cho_source', extract_srw('dc:source'), strip
to_field 'cho_subject', extract_srw('dc:subject'), strip

# Agg
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
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

to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash('agg_data_provider', 'agg_data_provider_country', 'agg_provider', 'agg_provider_country', 'cho_title')
