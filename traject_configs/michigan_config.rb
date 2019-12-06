# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/dlme_marc'
require 'macros/each_record'
require 'macros/timestamp'
require 'macros/version'
require 'traject/macros/marc21_semantics'
require 'traject/macros/marc_format_classifier'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::DlmeMarc
extend Macros::EachRecord
extend Macros::Timestamp
extend Macros::Version
extend Traject::Macros::Marc21
extend Traject::Macros::Marc21Semantics
extend Traject::Macros::MarcFormats
extend TrajectPlus::Macros

# NOTE: most of the fields are populated via marc_config

settings do
  provide 'reader_class_name', 'MARC::XMLReader'
  provide 'marc_source.type', 'xml'
end

to_field 'agg_data_provider_collection', collection

# # Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

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
  'cho_dc_rights',
  'cho_description',
  'cho_has_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
