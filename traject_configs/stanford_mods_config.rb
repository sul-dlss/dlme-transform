# frozen_string_literal: true

require 'macros/dlme'
require 'macros/each_record'

extend Macros::DLME
extend Macros::EachRecord
extend Macros::IIIF

each_record do |record, context|
  context.clipboard[:druid] = generate_druid(record, context)
  context.clipboard[:manifest] = "https://purl.stanford.edu/#{context.clipboard[:druid]}/iiif/manifest"
  context.clipboard[:iiif_json] = grab_iiif_manifest(context.clipboard[:manifest])
end

# Not using agg_has_view since we have the above
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

# Service Objects
def iiif_thumbnail_service(iiif_json)
  lambda { |_record, accumulator, context|
    accumulator << transform_values(context,
                                    'service_id' => literal(iiif_thumbnail_service_id(iiif_json)),
                                    'service_conforms_to' => literal(iiif_thumbnail_service_conforms_to(iiif_json)),
                                    'service_implements' => literal(iiif_thumbnail_service_protocol(iiif_json)))
  }
end

# Service Objects
def iiif_sequences_service(iiif_json)
  lambda { |_record, accumulator, context|
    accumulator << transform_values(context,
                                    'service_id' => literal(iiif_sequence_service_id(iiif_json)),
                                    'service_conforms_to' => literal(iiif_sequence_service_conforms_to(iiif_json)),
                                    'service_implements' => literal(iiif_sequence_service_protocol(iiif_json)))
  }
end

# STANFORD Specific
to_field 'cho_type', extract_mods('/*/mods:extension/rdf:RDF/rdf:Description/dc:format')
to_field 'cho_type', extract_mods('/*/mods:extension/rdf:RDF/rdf:Description/dc:type')

to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider_country',
  'agg_provider_country',
  'cho_type'
)
