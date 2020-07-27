# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/harvard'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/mods'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::Harvard
extend Macros::Mods
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Mods
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'cho_title', extract_mods('/*/*/mods:mods/mods:titleInfo/mods:title'), first_only, lang('en')
to_field 'cho_title', extract_mods('/*/*/mods:mods/mods:titleInfo/mods:title[@altRepGroup=02]'), lang('ar-Arab')
# to_field 'cho_title', extract_mods('/*/*/mods:mods/mods:titleInfo/mods:title[@altRepGroup=02]'), lang('ar-Per')
to_field 'id', extract_mods('/*/*/mods:mods/mods:recordInfo/mods:recordIdentifier'), strip

# CHO Other
to_field 'cho_alternative', extract_mods('/*/*/mods:mods/mods:titleInfo[@type]/mods:title'), lang('en')
to_field 'cho_creator', extract_mods('/*/*/mods:mods/mods:name/mods:namePart'), lang('en')
to_field 'cho_date', extract_mods('/*/*/mods:mods/mods:originInfo/*[@encoding="marc"]')
to_field 'cho_date_range_norm', harvard_ihp_date_range
to_field 'cho_date_range_hijri', harvard_ihp_date_range, hijri_range
to_field 'cho_description', extract_mods('/*/*/mods:mods/mods:note'), lang('en')
to_field 'cho_edm_type', extract_mods('/*/*/mods:mods/mods:typeOfResource[1]'), normalize_type, lang('en')
to_field 'cho_edm_type', extract_mods('/*/*/mods:mods/mods:typeOfResource[1]'), normalize_type, translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_mods('/*/*/mods:mods/mods:physicalDescription/mods:extent'), lang('en')
to_field 'cho_has_type', harvard_ihp_has_type, translation_map('norm_has_type_to_en'), lang('en')
to_field 'cho_has_type', harvard_ihp_has_type, translation_map('norm_has_type_to_en'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_is_part_of', literal('Islamic Heritage Project'), lang('en')
to_field 'cho_identifier', extract_mods('/*/*/mods:mods/mods:recordInfo/mods:recordIdentifier')
to_field 'cho_language', extract_mods('/*/*/mods:mods/mods:language/mods:languageTerm[1]'), normalize_language, lang('en')
to_field 'cho_language', extract_mods('/*/*/mods:mods/mods:language/mods:languageTerm[1]'), normalize_language, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_spatial', extract_mods('/*/*/mods:mods/mods:subject/mods:geographic'), lang('en')
to_field 'cho_subject', extract_mods('/*/*/mods:mods/mods:subject/mods:topic'), lang('en') # key error
to_field 'cho_type', extract_mods('/*/*/mods:mods/mods:typeOfResource'), lang('en')
to_field 'cho_type', extract_mods('/*/*/mods:mods/mods:genre'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_harvard('/*/*/mods:mods/mods:extension/HarvardDRS:DRSMetadata/HarvardDRS:drsObjectId'), first_only, strip, prepend('https://iiif.lib.harvard.edu/manifests/drs:')],
                                  # 'wr_id' => [extract_harvard('/*/*/mods:mods/mods:location/mods:url[@displayLabel="Islamic Heritage Project"][@access="object in context"]'), strip],
                                  'wr_is_referenced_by' => [extract_harvard('/*/*/mods:mods/mods:extension/HarvardDRS:DRSMetadata/HarvardDRS:drsObjectId'), first_only, strip, prepend('https://iiif.lib.harvard.edu/manifests/drs:')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_harvard('/*/*/mods:mods/mods:location/mods:url[@access="preview"]'), strip],
                                  'wr_is_referenced_by' => [extract_harvard('/*/*/mods:mods/mods:extension/HarvardDRS:DRSMetadata/HarvardDRS:drsObjectId'), first_only, strip, prepend('https://iiif.lib.harvard.edu/manifests/drs:')])
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
