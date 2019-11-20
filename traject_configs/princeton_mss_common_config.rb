# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/post_process'
require 'traject_plus'

extend Macros::DateParsing
extend Macros::DLME
<<<<<<< Updated upstream:traject_configs/princeton_mss_config.rb
extend Macros::PostProcess
=======
extend Macros::EachRecord
>>>>>>> Stashed changes:traject_configs/princeton_mss_common_config.rb
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

# Cho Required
to_field 'id', extract_json('.identifier')
to_field 'cho_title', extract_json('.title')

# Cho Other
to_field 'cho_alternate', extract_json('.cho_alternate')
<<<<<<< Updated upstream:traject_configs/princeton_mss_config.rb
to_field 'cho_creator', extract_json('.author')
to_field 'cho_contributor', extract_json('.contributor')
to_field 'cho_date', extract_json('.date')
to_field 'cho_date_range_norm', extract_json('.date'), parse_range
to_field 'cho_date_range_hijri', extract_json('.date'), parse_range, hijri_range
to_field 'cho_dc_rights', literal('https://rbsc.princeton.edu/services/imaging-publication-services')
to_field 'cho_description', extract_json('.description')
to_field 'cho_description', extract_json('.contents')
to_field 'cho_description', extract_json('.binding_note')
to_field 'cho_edm_type', literal('Text')
to_field 'cho_extent', extract_json('.extent')
to_field 'cho_identifier', extract_json('.source_metadata_identifier')
to_field 'cho_identifier', extract_json('.local_identifier')
to_field 'cho_identifier', extract_json('.alternate_identifier')
to_field 'cho_language', extract_json('.language')
to_field 'cho_provenance', extract_json('.provenance')
to_field 'cho_publisher', extract_json('.publisher')
to_field 'cho_subject', extract_json('.subject')
to_field 'cho_type', extract_json('.type')
=======
to_field 'cho_creator', extract_json('.author'), strip, lang('en')
to_field 'cho_date', extract_json('.date'), strip, lang('en')
to_field 'cho_date_range_norm', extract_json('.date'), parse_range
to_field 'cho_date_range_hijri', extract_json('.date'), parse_range, hijri_range
to_field 'cho_dc_rights', literal('https://rbsc.princeton.edu/services/imaging-publication-services'), strip, lang('en')
to_field 'cho_description', extract_json('.description'), strip, lang('en')
to_field 'cho_description', extract_json('.contents'), strip, lang('en')
to_field 'cho_description', extract_json('.binding_note'), strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.extent'), strip, lang('en')
to_field 'cho_has_type', literal('Manuscript'), lang('en')
to_field 'cho_has_type', literal('Manuscript'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.source_metadata_identifier')
to_field 'cho_identifier', extract_json('.local_identifier')
to_field 'cho_identifier', extract_json('.alternate_identifier')
to_field 'cho_language', extract_json('.language'), strip, lang('en')
to_field 'cho_language', extract_json('.language'), strip, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.provenance'), strip, lang('en')
to_field 'cho_publisher', extract_json('.publisher'), strip, lang('en')
to_field 'cho_subject', extract_json('.subject'), strip, lang('en')
to_field 'cho_type', extract_json('.type'), strip, lang('en')
>>>>>>> Stashed changes:traject_configs/princeton_mss_common_config.rb

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.identifier')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.thumbnail')]
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
  'cho_publisher',
  'cho_relation',
  'cho_source',
  'cho_spatial',
  'cho_subject',
  'cho_temporal',
  'cho_title',
  'cho_type'
)
