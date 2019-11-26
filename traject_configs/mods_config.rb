# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/mods'
require 'macros/normalize_type'
require 'macros/stanford'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::IIIF
extend Macros::Mods
extend Macros::NormalizeType
extend Macros::Stanford
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Mods
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

to_field 'agg_data_provider_collection', collection

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Spotlight DLME IR Record Identifier
to_field 'id', generate_mods_id

# CHO Required
to_field 'cho_identifier', extract_mods('/*/mods:identifier')
to_field 'cho_identifier', extract_mods('/*/mods:recordInfo/mods:recordIdentifier')
to_field 'cho_identifier', extract_mods('/*/mods:location/mods:holdingSimple/mods:copyInformation/mods:itemIdentifier')
to_field 'cho_language', normalize_mods_language
to_field 'cho_language', normalize_mods_script
to_field 'cho_title', extract_mods('/*/mods:titleInfo/mods:title')
to_field 'cho_title', extract_mods('/*/mods:titleInfo/mods:partName')
to_field 'cho_title', extract_mods('/*/mods:titleInfo/mods:partNumber')
to_field 'cho_title', extract_mods('/*/mods:titleInfo/mods:subTitle')

# CHO Other
to_field 'cho_alternative', extract_mods('/*/mods:titleInfo[@type]/mods:title')
to_field 'cho_coverage', extract_mods('/*/mods:originInfo/mods:dateValid')
to_field 'cho_coverage', extract_mods('/*/mods:originInfo/mods:place/mods:placeTerm')
to_field 'cho_creator', extract_name(role: %w[author creator])
to_field 'cho_contributor', extract_name(exclude: %w[author creator])
to_field 'cho_date', extract_mods('/*/mods:originInfo/mods:dateCreated')
to_field 'cho_date', extract_mods('/*/mods:originInfo/mods:copyrightDate')
to_field 'cho_date', extract_mods('/*/mods:originInfo/mods:dateIssued')
to_field 'cho_date_range_norm', mods_date_range
to_field 'cho_date_range_hijri', mods_date_range, hijri_range
to_field 'cho_dc_rights', first(
  extract_mods('/*/mods:accessCondition[@type="restrictionOnAccess"]/@xlink:href'),
  extract_mods('/*/mods:accessCondition[@type="restriction on access"]')
)
to_field 'cho_dc_rights', first(
  extract_mods('/*/mods:accessCondition[@type="useAndReproduction"]/@xlink:href'),
  extract_mods('/*/mods:accessCondition[@type="use and reproduction"]')
)
to_field 'cho_dc_rights', conditional(
  ->(_record, context) { context.output_hash['cho_dc_rights'].blank? },
  extract_mods('/*/mods:accessCondition')
)
to_field 'cho_description', extract_mods('/*/mods:abstract')
to_field 'cho_description', extract_mods('/*/mods:location/mods:holdingSimple/mods:copyInformation/mods:note')
to_field 'cho_description', extract_mods('/*/mods:note')
to_field 'cho_description', extract_mods('/*/mods:physicalDescription/mods:note')
to_field 'cho_description', extract_mods('/*/mods:tableOfContents')
to_field 'cho_edm_type', extract_mods('/*/mods:typeOfResource[1]'), normalize_type
to_field 'cho_extent', extract_mods('/*/mods:physicalDescription/mods:extent')
to_field 'cho_format', extract_mods('/*/mods:physicalDescription/mods:form')
to_field 'cho_has_part', generate_relation('/*/mods:relatedItem[@type="constituent"]')
to_field 'cho_type', extract_mods('/*/mods:genre')
to_field 'cho_is_part_of', generate_relation('/*/mods:relatedItem[@type="host"]')
to_field 'cho_is_part_of', generate_relation('/*/mods:relatedItem[@type="series"]')
to_field 'cho_publisher', extract_mods('/*/mods:originInfo/mods:publisher')
to_field 'cho_relation', generate_relation('/*/mods:relatedItem[not(@*)]')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:cartographics/mods:coordinates')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:cartographics/mods:projection')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:cartographics/mods:scale')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:geographic')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:geographicCode')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:area')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:city')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:citySection')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:continent')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:country')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:county')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:extraterrestrialArea')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:island')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:region')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:state')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:hierarchicalGeographic/mods:territory')
to_field 'cho_subject', extract_mods('/*/mods:classification')
to_field 'cho_subject', extract_mods('/*/mods:subject/mods:topic')
to_field 'cho_subject', extract_mods('/*/mods:subject/mods:titleInfo/mods:title')
to_field 'cho_temporal', extract_mods('/*/mods:subject/mods:temporal')
to_field 'cho_type', extract_mods('/*/mods:typeOfResource')

# Aggregation Object(s)
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')

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
