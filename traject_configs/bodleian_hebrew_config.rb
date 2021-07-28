# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/timestamp'
require 'macros/version'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::LanguageExtraction
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
to_field 'id', extract_json('.rendering'),
         strip,
         gsub('https://digital.bodleian.ox.ac.uk/inquire/p/', '')
to_field 'cho_title', extract_json('.title'), split(' ('), gsub(')', ''), gsub('(', ''), strip, hebrew_script_lang_or_default('he', 'und-Latn')

# Cho Other
to_field 'cho_creator', extract_json('.author'), strip, lang('en')
to_field 'cho_contributor', extract_json('.printer'), strip, append(' [printer]'), lang('en')
to_field 'cho_date', extract_json('.date_statement'), strip, lang('en')
to_field 'cho_date_range_norm', extract_json('.date_statement'), strip, gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', extract_json('.date_statement'), strip, gsub('/', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', literal('Photo: © Bodleian Libraries, University of Oxford, Terms of use: http://digital.bodleian.ox.ac.uk/terms.html'), lang('en')
to_field 'cho_description', extract_json('.description'), strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Manuscripts'), lang('en')
to_field 'cho_has_type', literal('Manuscripts'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_json('.catalogue_identifier'), strip
to_field 'cho_is_part_of', extract_json('.collection'), strip, lang('en')
to_field 'cho_language', literal('Hebrew'), lang('en')
to_field 'cho_language', literal('Hebrew'), translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_spatial', extract_json('.place_of_origin'), strip, gsub('[', ''), gsub(']', ''), lang('en')

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
    'wr_is_referenced_by' => [extract_json('.rendering'),
                              strip,
                              gsub('https://digital.bodleian.ox.ac.uk/inquire/p/', 'https://iiif.bodleian.ox.ac.uk/iiif/manifest/'),
                              append('.json')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.thumbnail'), strip],
    'wr_is_referenced_by' => [extract_json('.rendering'),
                              strip,
                              gsub('https://digital.bodleian.ox.ac.uk/inquire/p/', 'https://iiif.bodleian.ox.ac.uk/iiif/manifest/'),
                              append('.json')]
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
