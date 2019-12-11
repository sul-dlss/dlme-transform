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

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

each_record do |record, context|
  context.clipboard[:druid] = generate_druid(record, context)
  context.clipboard[:manifest] = "https://purl.stanford.edu/#{context.clipboard[:druid]}/iiif/manifest"
  context.clipboard[:iiif_json] = grab_iiif_manifest(context.clipboard[:manifest])
end

# Service Objects
def iiif_thumbnail_service(iiif_json)
  lambda { |_record, accumulator, context|
    accumulator << transform_values(context,
                                    'service_id' => literal(iiif_thumbnail_service_id(iiif_json)),
                                    'service_conforms_to' => literal(iiif_thumbnail_service_conforms_to(iiif_json)),
                                    'service_implements' => literal(iiif_thumbnail_service_protocol(iiif_json)))
  }
end

def iiif_sequences_service(iiif_json)
  lambda { |_record, accumulator, context|
    accumulator << transform_values(context,
                                    'service_id' => literal(iiif_sequence_service_id(iiif_json)),
                                    'service_conforms_to' => literal(iiif_sequence_service_conforms_to(iiif_json)),
                                    'service_implements' => literal(iiif_sequence_service_protocol(iiif_json)))
  }
end

# CHO Required
to_field 'id', generate_mods_id
to_field 'cho_title', extract_mods('/*/mods:titleInfo/mods:title'), lang('en')

# CHO Other
to_field 'cho_creator', extract_name(role: %w[author creator])
to_field 'cho_contributor', extract_name(exclude: %w[author creator]), lang('en')
to_field 'cho_date', extract_mods('/*/mods:originInfo/mods:dateCreated'), lang('en')
to_field 'cho_date', extract_mods('/*/mods:originInfo/mods:dateIssued'), lang('en')
to_field 'cho_date_range_norm', stanford_maps_date_range
to_field 'cho_date_range_hijri', stanford_maps_date_range, hijri_range
to_field 'cho_dc_rights', conditional(
  ->(_record, context) { context.output_hash['cho_dc_rights'].blank? },
  extract_mods('/*/mods:accessCondition')
), lang('en')
to_field 'cho_description', extract_mods('/*/mods:abstract'), lang('en')
to_field 'cho_description', extract_mods('/*/mods:note'), lang('en')
to_field 'cho_description', extract_mods('/*/mods:physicalDescription/mods:note'), lang('en')
to_field 'cho_description', extract_mods('/*/mods:tableOfContents'), lang('en')
to_field 'cho_edm_type', extract_mods('/*/mods:typeOfResource[1]'), normalize_type, lang('en')
to_field 'cho_edm_type', extract_mods('/*/mods:typeOfResource[1]'), normalize_type, translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_mods('/*/mods:physicalDescription/mods:extent'), lang('en')
to_field 'cho_format', extract_mods('/*/mods:physicalDescription/mods:form'), lang('en')
to_field 'cho_has_type', literal('Map'), lang('en')
to_field 'cho_has_type', literal('Map'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_has_part', generate_relation('/*/mods:relatedItem[@type="constituent"]')
to_field 'cho_identifier', extract_mods('/*/mods:identifier')
to_field 'cho_identifier', extract_mods('/*/mods:recordInfo/mods:recordIdentifier')
to_field 'cho_is_part_of', generate_relation('/*/mods:relatedItem[@type="host"]')
to_field 'cho_language', normalize_mods_language, lang('en')
to_field 'cho_language', normalize_mods_language, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_publisher', extract_mods('/*/mods:originInfo/mods:publisher'), lang('en')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:cartographics/mods:coordinates'), lang('en')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:cartographics/mods:projection'), lang('en')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:cartographics/mods:scale'), lang('en')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:geographic'), lang('en')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:geographicCode'), lang('en')
to_field 'cho_subject', extract_mods('/*/mods:classification'), lang('en')
to_field 'cho_subject', extract_mods('/*/mods:subject/mods:topic'), lang('en')
to_field 'cho_temporal', extract_mods('/*/mods:subject/mods:temporal'), lang('en')
to_field 'cho_type', extract_mods('/*/mods:typeOfResource'), lang('en')
to_field 'cho_type', extract_mods('/*/mods:genre'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => literal(generate_sul_shown_at(record, context.clipboard[:druid])))
end
to_field 'agg_is_shown_by' do |_record, accumulator, context|
  if context.clipboard[:iiif_json].present?
    iiif_json = context.clipboard[:iiif_json]
    accumulator << transform_values(context,
                                    'wr_description' => [
                                      extract_mods('/*/mods:physicalDescription/mods:digitalOrigin'),
                                      extract_mods('/*/mods:physicalDescription/mods:reformattingQuality')
                                    ],
                                    'wr_format' => extract_mods('/*/mods:physicalDescription/mods:internetMediaType'),
                                    'wr_has_service' => iiif_sequences_service(iiif_json),
                                    'wr_id' => literal(iiif_sequence_id(iiif_json)),
                                    'wr_is_referenced_by' => literal(context.clipboard[:manifest]))
  end
end
to_field 'agg_preview' do |_record, accumulator, context|
  if context.clipboard[:iiif_json].present?
    iiif_json = context.clipboard[:iiif_json]
    accumulator << transform_values(context,
                                    'wr_format' => extract_mods('/*/mods:physicalDescription/mods:internetMediaType'),
                                    'wr_has_service' => iiif_thumbnail_service(iiif_json),
                                    'wr_id' => literal(iiif_thumbnail_id(iiif_json)),
                                    'wr_is_referenced_by' => literal(context.clipboard[:manifest]))
  else
    accumulator << transform_values(context,
                                    'wr_format' => literal('image/jpeg'),
                                    'wr_id' => literal("https://stacks.stanford.edu/file/druid:#{context.clipboard[:druid]}/preview.jpg"))
  end
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
