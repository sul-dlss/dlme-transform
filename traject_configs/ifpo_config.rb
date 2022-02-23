# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/csv'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'

extend Macros::Csv
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
end

# File path
to_field 'dlme_source_file', path_to_file

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Intentionally not mapping agg_is_shown_by, cho_alternate, cho_extent, cho_format,
# cho_has_part, cho_medium, cho_provenance, cho_relation, cho_same_as, cho_spatial, and
# cho_temporal as these values are not available in the data harvested from the provider
# Also not mapping cho_is_part_of as it is the same info provided in agg_data_provider_collection.

to_field 'agg_data_provider_collection_id', literal('ifpo-photographs')
to_field 'agg_data_provider_collection', literal('ifpo-photographs'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection', literal('ifpo-photographs'), translation_map('agg_collection_from_provider_id'), lang('en')

# Cho Required
to_field 'id', column('id'), split('-'), last
to_field 'cho_title', column('title_en'), lang('en')
to_field 'cho_title', column('title_fr'), lang('fr')

# Cho Other
to_field 'cho_contributor', column('contributor'), parse_csv, lang('en')
to_field 'cho_coverage', column('coverage'), parse_csv, lang('en')
to_field 'cho_creator', column('creator'), parse_csv, lang('en')
to_field 'cho_date', column('date'), lang('en')
to_field 'cho_date_range_norm', column('date'), split('-'), first_only, parse_range
to_field 'cho_date_range_hijri', column('date'), split('-'), first_only, parse_range, hijri_range
to_field 'cho_dc_rights', column('rights'), parse_csv, lang('en')
to_field 'cho_description', column('description_en'), parse_csv, lang('en')
to_field 'cho_description', column('description_fr'), parse_csv, lang('fr')
to_field 'cho_edm_type', column('type'), parse_csv, last, transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), lang('ar-Arab') # Arabic value
to_field 'cho_edm_type', column('type'), parse_csv, last, transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('edm_type_from_has_type'), lang('en') # English value
to_field 'cho_has_type', column('type'), parse_csv, last, transform(&:downcase), translation_map('has_type_from_contributor'), translation_map('has_type_ar_from_en'), lang('ar-Arab') # Arabic value
to_field 'cho_has_type', column('type'), parse_csv, last, transform(&:downcase), translation_map('has_type_from_contributor'), lang('en') # English value
to_field 'cho_identifier', column('identifier'), parse_csv
to_field 'cho_language', column('language'), normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')
to_field 'cho_language', column('language'), normalize_language, lang('en')
to_field 'cho_publisher', column('publisher'), parse_csv, lang('en')
to_field 'cho_source', column('source'), parse_csv, lang('en')
to_field 'cho_subject', column('subject_ar'), parse_csv, lang('ar-Arab')
to_field 'cho_subject', column('subject_en'), parse_csv, lang('en')
to_field 'cho_subject', column('subject_fr'), parse_csv, lang('fr')
to_field 'cho_type', column('type'), parse_csv, last, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('id'), split(':'), last, gsub('v1', ''), prepend('https://medihal.archives-ouvertes.fr/')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [column('id'), split(':'), last, gsub('v1', ''), prepend('https://medihal.archives-ouvertes.fr/'), append('/thumb')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider',
  'agg_data_provider_collection',
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
# This may be used as an alternative to building 'cho_type_facet' directly,
# Don't use both.
each_record add_cho_type_facet
