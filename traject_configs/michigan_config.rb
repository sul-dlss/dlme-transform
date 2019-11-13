# frozen_string_literal: true

# NOTE: most of the fields are populated via marc_config

settings do
  provide 'reader_class_name', 'MARC::XMLReader'
  provide 'marc_source.type', 'xml'
end

# Cho Additional
to_field 'cho_dc_rights', literal('Public Domain'), lang('en')
to_field 'cho_description', extract_marc('500a:505agrtu:520abcu', alternate_script: false), strip, gsub('Special Collections Library,', 'Special Collections Research Center'), lang('en')
to_field 'cho_description', extract_marc('500a:505agrtu:520abcu', alternate_script: :only), strip, lang('ar-Arab')
to_field 'cho_has_type', literal('Manuscript'), lang('en')
to_field 'cho_has_type', literal('Manuscript'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', oclcnum
to_field 'cho_same_as', extract_marc('001'), strip, prepend('https://catalog.hathitrust.org/Record/')

# Agg Additional
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_marc('001'),
                strip,
                prepend('https://search.lib.umich.edu/catalog/record/')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_marc('974u'),
                strip,
                prepend('https://babel.hathitrust.org/cgi/imgsrv/image?id='),
                append(';seq=7;size=25;rotation=0')]
  )
end

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
