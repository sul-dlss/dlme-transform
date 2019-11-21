# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Csv
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# CHO Required
to_field 'id', column('Resource_URL')
to_field 'cho_title', column('Title'), strip, lang('en')

# CHO Other
to_field 'cho_creator', column('Creator'), strip, lang('en')
to_field 'cho_date', column('Date'), strip, lang('en')
to_field 'cho_date_range_norm', column('Date'), parse_range
to_field 'cho_date_range_hijri', column('Date'), parse_range, hijri_range
to_field 'cho_description', column('Description'), strip, lang('en')
to_field 'cho_edm_type', literal('Image'), lang('en')
to_field 'cho_edm_type', literal('Image'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_has_type', literal('Poster'), lang('en')
to_field 'cho_has_type', literal('Poster'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', column('Resource-URL')
to_field 'cho_dc_rights', literal("The PPPA operates according to the principles of 'fair use'. According to fair use principles, an author may make limited use of another author's work without asking for permission. Fair use is based on the belief that the public is entitled to freely use portions of copyrighted materials for non-commercial educational purposes, commentary and criticism. For full rights policy, see: https://www.palestineposterproject.org/content/faq"), lang('en')
to_field 'cho_subject', column('Subject'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('Resource_URL')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [column('Thumbnail')])
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
