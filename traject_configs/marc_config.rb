# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/dlme_marc'
require 'macros/each_record'
require 'traject/macros/marc21_semantics'
require 'traject/macros/marc_format_classifier'

extend Macros::DLME
extend Macros::DateParsing
extend Macros::DlmeMarc
extend Macros::EachRecord
extend Traject::Macros::Marc21
extend Traject::Macros::Marc21Semantics
extend Traject::Macros::MarcFormats
extend TrajectPlus::Macros

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'MarcReader'
end

to_field 'id', extract_marc('001', first: true) do |_record, accumulator, _context|
  accumulator.collect! { |s| "penn_#{s}" }
end

# CHO Required
to_field 'cho_identifier', extract_marc('001')
to_field 'cho_identifier', extract_marc('010a')
to_field 'cho_identifier', oclcnum
to_field 'cho_language', transform(&:downcase), translation_map('not_found', 'languages', 'marc_languages')
to_field 'cho_title', extract_marc('245', trim_punctuation: true)

# CHO Other
to_field 'cho_alternative', extract_marc('130:240:246')
to_field 'cho_contributor', extract_role('700', 'contributor')
to_field 'cho_contributor', extract_role('710', 'contributor')
to_field 'cho_contributor', extract_role('711', 'contributor')
# to_field 'cho_coverage', ?
to_field 'cho_creator', extract_marc('100:110:111', trim_punctuation: true)
to_field 'cho_creator', extract_role('700', 'creator')
to_field 'cho_creator', extract_role('710', 'creator')
to_field 'cho_creator', extract_role('711', 'creator')
to_field 'cho_date', marc_publication_date, transform(&:to_s)
to_field 'cho_date_range_norm', extract_marc('008[06-14]'), marc_date_range
to_field 'cho_date_range_hijri', extract_marc('008[06-14]'), marc_date_range, hijri_range
# to_field 'cho_dc_rights', ?
to_field 'cho_description', extract_marc('500:505:520')
to_field 'cho_edm_type', marc_type_to_edm
to_field 'cho_extent', extract_marc('300a', separator: nil, trim_punctuation: true)
to_field 'cho_format', marc_formats
# to_field 'cho_has_part', ?
to_field 'cho_type', extract_marc('651a', trim_punctuation: true)
to_field 'cho_is_part_of', extract_marc('440a:490a:800abcdt:400abcd:810abcdt:410abcd:811acdeft:411acdef:830adfgklmnoprst:760ast')
to_field 'cho_medium', extract_marc('300b', trim_punctuation: true)
# fo_field 'cho_provenance', ?
to_field 'cho_publisher', extract_marc('260b:264b', trim_punctuation: true)
# to_field 'cho_relation'
# to_field 'cho_source'
to_field 'cho_spatial', marc_geo_facet
to_field 'cho_subject', extract_marc('600:610:611:630:650:651:653:654:690:691:692')
to_field 'cho_temporal', marc_era_facet
to_field 'cho_type', marc_type_to_edm

# Agg Required
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  values = transform_values(context, 'wr_id' => extract_marc('856u', first: true))
  if values.fetch('wr_id', []).empty?
    values = transform_values(context, 'wr_id' => [extract_marc('001', first: true),
                                                   prepend('http://hdl.library.upenn.edu/1017/d/medren/')])
  end
  accumulator << values
end

to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

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
