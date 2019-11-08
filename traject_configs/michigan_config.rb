# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/michigan'
require 'macros/oai'
require 'traject_plus'

extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::Michigan
extend Macros::OAI
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Cho Required
to_field 'id', extract_xpath("//controlfield[@tag='001']"), strip
to_field 'cho_title', extract_xpath("//datafield[@tag='245']/subfield[@code='a']")
to_field 'cho_title', extract_xpath("//datafield[@tag='880']/subfield[contains(text(),'245-03/')]/../subfield[@code='a']"), strip
to_field 'cho_title', extract_xpath("//datafield[@tag='880']/subfield[contains(text(),'240-02/')]/../subfield[@code='a']"), strip

# Cho Other
to_field 'cho_creator', extract_xpath("//datafield[@tag='100']/subfield[@code='a']")
to_field 'cho_creator', extract_xpath("//datafield[@tag='880']/subfield[contains(text(),'100-01/')]/../subfield[@code='a']"), strip
to_field 'cho_date', extract_xpath("//datafield[@tag='260']"), strip
to_field 'cho_date_range_norm', extract_xpath("//controlfield[@tag='008']"),
         ->(_rec, acc) { acc.map! { |raw| raw[6..14] } },
         marc_date_range
to_field 'cho_date_range_hijri', extract_xpath("//controlfield[@tag='008']"),
         ->(_rec, acc) { acc.map! { |raw| raw[6..14] } },
         marc_date_range,
         hijri_range
to_field 'cho_description', extract_xpath("//datafield[@tag='300']"), strip
to_field 'cho_description', extract_xpath("//datafield[@tag='520']"), strip
to_field 'cho_description', extract_xpath("//datafield[@tag='500']"),
         strip,
         gsub('Special Collections Library,', 'Special Collections Research Center')
to_field 'cho_description', extract_xpath("//datafield[@tag='510']"), strip
to_field 'cho_dc_rights', literal('Public Domain')
to_field 'cho_edm_type', literal('Text')
to_field 'cho_language', extract_xpath("//controlfield[@tag='008']"),
         strip,
         transform(&:to_s),
         transform(&:downcase),
         gsub(' d', ''),
         split(' '),
         last_only,
         gsub('||', ''),
         translation_map('not_found', 'marc_languages', 'iso_639-2')
to_field 'cho_subject', extract_xpath("//datafield[@tag='650']"), strip
to_field 'cho_same_as', extract_xpath("//controlfield[@tag='001']"), strip, prepend('https://catalog.hathitrust.org/Record/')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_xpath("//controlfield[@tag='001']"), strip, prepend('https://search.lib.umich.edu/catalog/record/')]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_xpath("//datafield[@tag='974']/subfield[@code='u']"),
                strip,
                prepend('https://babel.hathitrust.org/cgi/imgsrv/image?id='),
                append(';seq=7;size=25;rotation=0')]
  )
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')

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
