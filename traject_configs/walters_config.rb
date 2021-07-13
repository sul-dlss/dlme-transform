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
require 'macros/walters'
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
extend Macros::Walters
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

require 'pathname'

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', extract_json('.ObjectNumber')
to_field 'cho_title', extract_json('.Title'), lang('en')

# Cho Other
to_field 'cho_creator', extract_json('.Creator'), lang('en')
to_field 'cho_date', extract_json('.DateText'), lang('en')
to_field 'cho_date_range_norm', generate_object_date, parse_range
to_field 'cho_date_range_hijri', generate_object_date, parse_range, hijri_range
to_field 'cho_dc_rights', literal('Public Domain'), lang('en')
to_field 'cho_description', extract_json('.Description'), lang('en')
to_field 'cho_description', extract_json('.Dynasty'), prepend('Dynasty: '), lang('en')
to_field 'cho_description', extract_json('.Inscriptions'), lang('en')
to_field 'cho_description', extract_json('.Reign'), lang('en')
to_field 'cho_description', extract_json('.Style'), lang('en')
to_field 'cho_edm_type', generate_has_type, normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', generate_has_type, normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.Dimensions'), prepend('Dimensions: '), lang('en')
to_field 'cho_has_type', generate_edm_type, normalize_has_type, lang('en')
to_field 'cho_has_type', generate_edm_type, normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.ObjectNumber')
to_field 'cho_identifier', extract_json('.SortNumber')
to_field 'cho_is_part_of', extract_json('.Collection'), lang('en')
to_field 'cho_medium', extract_json('.Medium'), lang('en')
to_field 'cho_provenance', extract_json('.Provenance'), lang('en')
to_field 'cho_subject', extract_json('.Culture'), prepend('Culture: '), lang('en')
to_field 'cho_subject', extract_json('.Keywords'), lang('en')
to_field 'cho_temporal', extract_json('.Period'), lang('en')
to_field 'cho_type', extract_json('.Classification'), lang('en')
to_field 'cho_type', extract_json('.ObjectName'), split(';'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_edm_rights', literal('CC0: https://creativecommons.org/publicdomain/zero/1.0/')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_edm_rights' => literal('CC0: https://creativecommons.org/publicdomain/zero/1.0/'),
                                  'wr_id' => [extract_json('.ResourceURL')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_edm_rights' => literal('CC0: https://creativecommons.org/publicdomain/zero/1.0/'),
                                  'wr_id' => generate_preview)
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
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
