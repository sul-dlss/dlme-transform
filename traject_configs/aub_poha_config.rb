# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/aub'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/oai'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::AUB
extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::FieldExtraction
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::OAI
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# File path
to_field 'dlme_source_file', path_to_file

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Cho Required
to_field 'id', extract_xpath('/*/identifier'), strip
to_field 'cho_title', extract_poha('/*/dc:title'), strip, arabic_script_lang_or_default('ar-Arab', 'en')
to_field 'cho_title', extract_poha('/*/dc:title[2]'), strip, arabic_script_lang_or_default('ar-Arab', 'en')

# Cho Other
to_field 'cho_contributor', extract_poha('/*/dc:interviewee'), strip, prepend('Interviewee: '), lang('en')
to_field 'cho_contributor', extract_poha('/*/dc:intervieweeAR'), strip, lang('ar-Arab')
to_field 'cho_contributor', extract_poha('/*/dc:interviewer'), strip, prepend('Interviewer: '), lang('en')
to_field 'cho_contributor', extract_poha('/*/dc:interviewerAR'), strip, lang('ar-Arab')
to_field 'cho_date', extract_poha('/*/dc:date[1]'), strip, lang('en')
to_field 'cho_date_range_hijri', extract_poha('/*/dc:date[1]'), strip, parse_range, hijri_range
to_field 'cho_date_range_norm', extract_poha('/*/dc:date[1]'), strip, parse_range
to_field 'cho_dc_rights', literal('Available under a Creative Commons Attribution-Noncommercial-NoDerivatives '\
                           '4.0 International License. Anyone is free to download and share works under '\
                           'this license as long as they give credit for the original creation, the '\
                           'shared work is not changed and not used for commercial purposes. '\
                           'Attribution should be given to "AUB University Libraries." e.g. "Campus '\
                           '1967" by AUB University Libraries is licensed under CC BY-NC-ND 4.0'), lang('en')
to_field 'cho_description', extract_poha('/*/dc:biography'), strip, lang('en')
to_field 'cho_description', extract_poha('/*/dc:biographyAR'), strip, lang('ar-Arab')
to_field 'cho_description', extract_poha('/*/dc:description'), strip, lang('en')
to_field 'cho_description', xpath_commas_with_prepend('/*/dc:toc', 'Table of Contents: '), lang('en')
to_field 'cho_description', xpath_commas_with_prepend('/*/dc:toc', 'جدول المحتويات:'), lang('ar-Arab')
to_field 'cho_edm_type', literal('Sound'), lang('en')
to_field 'cho_edm_type', literal('Sound'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_poha('/*/dc:duration'), strip, prepend('Duration: '), lang('en')
to_field 'cho_has_type', literal('Oral History'), lang('en')
to_field 'cho_has_type', literal('Oral History'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_poha('/*/dc:format'), strip, lang('en')
to_field 'cho_identifier', extract_poha('/*/dc:identifier'), strip
to_field 'cho_identifier', extract_poha('/*/dc:localID'), strip
to_field 'cho_is_part_of', extract_poha('/*/dc:collectionName'), strip, lang('en')
to_field 'cho_is_part_of', extract_poha('/*/dc:collectionNameAR'), strip, lang('ar-Arab')
to_field 'cho_language', literal('Arabic'), lang('en')
to_field 'cho_language', literal('Arabic'), translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_dc_rights', literal('The copyright holder of this interview is the Nakba Archive, all rights reserved.'), lang('en')
to_field 'cho_spatial', extract_poha('/*/dc:village'), strip, lang('en')
to_field 'cho_spatial', extract_poha('/*/dc:villageAR'), strip, lang('ar-Arab')
to_field 'cho_subject', extract_poha('/*/dc:subject'), strip, lang('en')
to_field 'cho_subject', extract_poha('/*/dc:subjectAR'), strip, lang('ar-Arab')
to_field 'cho_subject', extract_poha('/*/dc:otherSubject'), strip, lang('en')
to_field 'cho_type', extract_poha('/*/dc:type'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_dc_rights' => [literal('Available under a Creative Commons Attribution-Noncommercial-NoDerivatives '\
                               '4.0 International License. Anyone is free to download and share works under '\
                               'this license as long as they give credit for the original creation, the '\
                               'shared work is not changed and not used for commercial purposes. '\
                               'Attribution should be given to "AUB University Libraries." e.g. "Campus '\
                               '1967" by AUB University Libraries is licensed under CC BY-NC-ND 4.0')],
    'wr_edm_rights' => [literal('CC BY-ND: https://creativecommons.org/licenses/by-nd/4.0/')],
    'wr_id' => [extract_poha('/*/dc:identifierURI'), strip]
  )
end
each_record do |record|
  next if record.xpath('/*/dc:thumbnail', NS).map(&:text).blank?

  to_field 'agg_preview' do |_record, accumulator, context|
    accumulator << transform_values(
      context,
      'wr_dc_rights' => [literal('Available under a Creative Commons Attribution-Noncommercial-NoDerivatives '\
                           '4.0 International License. Anyone is free to download and share works under '\
                           'this license as long as they give credit for the original creation, the '\
                           'shared work is not changed and not used for commercial purposes. '\
                           'Attribution should be given to "AUB University Libraries." e.g. "Campus '\
                           '1967" by AUB University Libraries is licensed under CC BY-NC-ND 4.0')],
      'wr_edm_rights' => [literal('CC BY-ND: https://creativecommons.org/licenses/by-nd/4.0/')],
      'wr_id' => [extract_poha('/*/dc:thumbnail')]
    )
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
