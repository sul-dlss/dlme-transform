# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/iiif'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/qnl'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::IIIF
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::QNL
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

each_record do |record, context|
  context.clipboard[:id] = generate_qnl_iiif_id(record, context)
  context.clipboard[:manifest] = "https://www.qdl.qa/en/iiif/#{context.clipboard[:id]}/manifest"
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
to_field 'id', extract_qnl_identifier, strip
to_field 'cho_title', extract_qnl_ar('mods:titleInfo/mods:title'), lang('ar-Arab')
to_field 'cho_title', extract_qnl_en('mods:titleInfo/mods:title'), lang('en')

# CHO Other
to_field 'cho_contributor', name_with_role('en'), lang('en')
to_field 'cho_contributor', name_with_role('ar'), lang('ar-Arab')
to_field 'cho_date', extract_qnl_en('mods:originInfo/mods:dateIssued'), strip
to_field 'cho_date_range_norm', extract_qnl_en('mods:originInfo/mods:dateIssued'), strip, gsub('/', '-'), parse_range
to_field 'cho_date_range_hijri', extract_qnl_en('mods:originInfo/mods:dateIssued'),
         strip, gsub('/', '-'), parse_range, hijri_range
to_field 'cho_dc_rights', extract_qnl_ar('mods:accessCondition'), lang('ar-Arab')
to_field 'cho_dc_rights', extract_qnl_en('mods:accessCondition'), lang('en')
to_field 'cho_description', extract_qnl_ar('mods:abstract'), strip, lang('ar-Arab')
to_field 'cho_description', extract_qnl_en('mods:abstract'), strip, lang('en')
to_field 'cho_description', extract_qnl_ar('mods:physicalDescription/mods:extent'), strip, lang('ar-Arab')
to_field 'cho_description', extract_qnl_en('mods:physicalDescription/mods:extent'), strip, lang('en')
to_field 'cho_edm_type', extract_qnl_en('mods:genre'), normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', extract_qnl_en('mods:genre'), normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_qnl_ar('mods:physicalDescription/mods:extent[1]'), strip, lang('ar-Arab')
to_field 'cho_extent', extract_qnl_en('mods:physicalDescription/mods:extent[1]'), strip, lang('en')
to_field 'cho_has_type', extract_qnl_en('mods:genre'), normalize_has_type, lang('en')
to_field 'cho_has_type', extract_qnl_en('mods:genre'), normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_identifier', extract_qnl_ar('mods:identifier'), strip
to_field 'cho_identifier', extract_qnl_en('mods:identifier'), strip
to_field 'cho_identifier', extract_qnl_en('mods:recordInfo/mods:recordIdentifier'), strip
to_field 'cho_identifier', extract_qnl_en('mods:location/mods:shelfLocator'), strip
to_field 'cho_is_part_of', extract_qnl_ar('mods:location/mods:physicalLocation'), strip, lang('ar-Arab')
to_field 'cho_is_part_of', extract_qnl_en('mods:location/mods:physicalLocation'), strip, lang('en')
to_field 'cho_language', extract_qnl_en('mods:language/mods:languageTerm'), normalize_language, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_language', extract_qnl_en('mods:language/mods:languageTerm'), normalize_language, lang('en')
to_field 'cho_spatial', extract_qnl_ar('mods:subject/mods:geographic'), strip, lang('ar-Arab')
to_field 'cho_spatial', extract_qnl_en('mods:subject/mods:geographic'), strip, lang('en')
to_field 'cho_subject', extract_qnl_ar('mods:subject/mods:topic'), strip, lang('ar-Arab')
to_field 'cho_subject', extract_qnl_en('mods:subject/mods:topic'), strip, lang('en')
to_field 'cho_type', extract_qnl_ar('mods:genre'), strip, lang('ar-Arab')
to_field 'cho_type', extract_qnl_en('mods:genre'), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [extract_qnl_en('mods:accessCondition'), strip],
    'wr_edm_rights' => [extract_qnl_en('mods:accessCondition'), strip, translation_map('edm_rights')],
    'wr_format' => [literal('image/jpeg')],
    'wr_id' => [literal("https://www.qdl.qa/en/mirador/#{context.clipboard[:id]}")],
    'wr_is_referenced_by' => [extract_qnl_en('mods:location/mods:url[@access="preview"]'), strip, split('vdc_'), last, split('/'), first_only, prepend('https://www.qdl.qa/en/iiif/81055/vdc_'), append('/manifest')]
  )
end
to_field 'agg_is_shown_by' do |_record, accumulator, context|
  if context.clipboard[:iiif_json].present?
    iiif_json = context.clipboard[:iiif_json]
    accumulator << transform_values(
      context,
      'wr_edm_rights' => [extract_qnl_en('mods:accessCondition'), strip, translation_map('edm_rights'), translation_map('not_found')],
      'wr_format' => [literal('image/jpeg')],
      'wr_has_service' => iiif_sequences_service(iiif_json),
      'wr_id' => literal(iiif_sequence_id(iiif_json)),
      'wr_is_referenced_by' => literal(context.clipboard[:manifest])
    )
  else
    accumulator << transform_values(context,
                                    'wr_edm_rights' => [extract_qnl_en('mods:accessCondition'), strip, translation_map('edm_rights'), translation_map('not_found')],
                                    'wr_format' => literal('image/jpeg'),
                                    'wr_id' => literal(context.clipboard[:id]),
                                    'wr_is_referenced_by' => literal(context.clipboard[:manifest]))
  end
end
to_field 'agg_preview' do |_record, accumulator, context|
  if context.clipboard[:iiif_json].present?
    iiif_json = context.clipboard[:iiif_json]
    accumulator << transform_values(context,
                                    'wr_edm_rights' => [extract_qnl_en('mods:accessCondition'), strip, translation_map('edm_rights')],
                                    'wr_format' => [literal('image/jpeg')],
                                    'wr_has_service' => iiif_thumbnail_service(iiif_json),
                                    'wr_id' => literal(iiif_thumbnail_id(iiif_json)),
                                    'wr_is_referenced_by' => literal(context.clipboard[:manifest]))
  else
    accumulator << transform_values(context,
                                    'wr_edm_rights' => [extract_qnl_en('mods:accessCondition'), strip, translation_map('edm_rights')],
                                    'wr_format' => literal('image/jpeg'),
                                    'wr_id' => literal(context.clipboard[:id]),
                                    'wr_is_referenced_by' => literal(context.clipboard[:manifest]))
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
