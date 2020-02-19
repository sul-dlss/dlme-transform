# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_language'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::NormalizeLanguage
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

# Cho Required
to_field 'id', extract_json('.rendering'), strip
# uniform_title is not being used but should be if authority control is applied to title field
to_field 'cho_title', extract_json('.dlme_title_ara_arab'), lang('ar-Arab')
to_field 'cho_title', extract_json('.dlme_title_ara_latn'), lang('ar-Latn')
to_field 'cho_title', extract_json('.dlme_title_en'), lang('en')
to_field 'cho_title', extract_json('.dlme_title_none')
to_field 'cho_title', extract_json('.dlme_title_ota_arab'), lang('tr-Arab')
to_field 'cho_title', extract_json('.dlme_title_ota_latn'), lang('tr-Latn')
to_field 'cho_title', extract_json('.dlme_title_per_arab'), lang('fa-Arab')
to_field 'cho_title', extract_json('.dlme_title_per_latn'), lang('fa-Latn')
to_field 'cho_title', extract_json('.dlme_title_urdu_latn'), lang('ur-Latn')

# Cho Other
to_field 'cho_creator', extract_json('.dlme_creator_ara_latn'), strip, lang('ar-Latn')
to_field 'cho_creator', extract_json('.dlme_creator_ara_arab'), strip, lang('ar-Arab')
to_field 'cho_contributor', extract_json('.dlme_contributor_ara_latn'), strip, lang('ar-Latn')
to_field 'cho_contributor', extract_json('.dlme_contributor_ara_arab'), strip, lang('ar-Arab')
to_field 'cho_date', extract_json('.date[0]'), strip, lang('en')
to_field 'cho_date_range_norm', extract_json('.date[0]'), strip, parse_range
to_field 'cho_date_range_hijri', extract_json('.date[0]'), strip, parse_range, hijri_range
to_field 'cho_dc_rights', literal('https://rbsc.princeton.edu/services/imaging-publication-services')
to_field 'cho_description', extract_json('.description'), strip, lang('en')
to_field 'cho_description', extract_json('.contents[0]'), strip, lang('en')
to_field 'cho_description', extract_json('.binding_note[0]'), strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.extent[0]'), strip, lang('en')
to_field 'cho_extent', extract_json('.extent[1]'), strip, lang('ar-Arab')
to_field 'cho_has_type', literal('Manuscript'), lang('en')
to_field 'cho_has_type', literal('Manuscript'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.source_metadata_identifier[0]'), strip
to_field 'cho_identifier', extract_json('.identifier[0]'), strip
to_field 'cho_identifier', extract_json('.local_identifier[0]'), strip
to_field 'cho_language', extract_json('.language[0]'), strip, normalize_language, lang('en')
to_field 'cho_language', extract_json('.language[0]'), strip, normalize_language, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_provenance', extract_json('.dlme_en'), strip, lang('en')
to_field 'cho_provenance', extract_json('.dlme_provenance_ara_arab'), strip, lang('ar-Arab')
to_field 'cho_publisher', extract_json('.publisher[0]'), strip, lang('en')
to_field 'cho_publisher', extract_json('.publisher[1]'), strip, lang('ar-Arab')
to_field 'cho_subject', extract_json('.subject[0]'), strip, lang('en')
to_field 'cho_type', extract_json('.type[0]'), lang('en')
to_field 'cho_type', extract_json('.type[1]'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.rendering'), strip],
    'wr_is_referenced_by' => extract_json('.iiif_manifest')
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => extract_json('.thumbnail'),
                                  'wr_is_referenced_by' => extract_json('.iiif_manifest')
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

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
