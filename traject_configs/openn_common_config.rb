# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/normalize_language'
require 'macros/timestamp'
require 'macros/version'
require 'macros/tei'
require 'traject_plus'

extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::NormalizeLanguage
extend Macros::Tei
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Tei
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# Constants
MS_CONTENTS = 'tei:msContents'
MS_DESC = '/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc'
MS_ID = 'tei:msIdentifier'
MS_ITEM = 'tei:msItem'
MS_ORIGIN = 'tei:history/tei:origin'
OBJ_DESC = 'tei:physDesc/tei:objectDesc'
PROFILE_DESC = '/*/tei:teiHeader/tei:profileDesc/tei:textClass'
PUB_STMT = '/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt'
SUPPORT_DESC = 'tei:supportDesc[@material="paper"]'

# CHO Required
to_field 'id', lambda { |_record, accumulator, context|
  bare_id = default_identifier(context)
  accumulator << identifier_with_prefix(context, bare_id)
}
to_field 'cho_title', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:title[1]"), strip
to_field 'cho_title', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:title[@type='vernacular']"), strip, lang('ar-Arab')

# CHO Other
to_field 'cho_date', extract_tei("#{MS_DESC}/#{MS_ORIGIN}/tei:origDate"), strip, lang('en')
to_field 'cho_dc_rights', extract_tei("#{PUB_STMT}/tei:availability/tei:licence"), strip, lang('en')
to_field 'cho_description', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/tei:summary"), strip, lang('en')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_tei("#{MS_DESC}/#{OBJ_DESC}/tei:layoutDesc/tei:layout")
to_field 'cho_extent', extract_tei("#{MS_DESC}/#{OBJ_DESC}/#{SUPPORT_DESC}/tei:extent")
to_field 'cho_has_type', literal('Manuscript'), lang('en')
to_field 'cho_has_type', literal('Manuscript'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_identifier', extract_tei("#{MS_DESC}/#{MS_ID}/tei:idno[@type='call-number']")
to_field 'cho_language', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/tei:textLang/@mainLang"), normalize_language, lang('en')
to_field 'cho_language', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/tei:textLang/@mainLang"), normalize_language, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_provenance', extract_tei("#{MS_DESC}/tei:history/tei:provenance"), strip, lang('en')
to_field 'cho_publisher', extract_tei("#{PUB_STMT}/tei:publisher"), strip, lang('en')
to_field 'cho_spatial', extract_tei("#{MS_DESC}/#{MS_ORIGIN}/tei:origPlace"), strip, lang('en')
to_field 'cho_subject', extract_tei("#{PROFILE_DESC}/tei:keywords[@n='form/genre']/tei:term"), strip, lang('en')
to_field 'cho_subject', extract_tei("#{PROFILE_DESC}/tei:keywords[@n='subjects']/tei:term"), strip, lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_edm_rights', public_domain
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [extract_tei("#{MS_DESC}/#{MS_ID}/tei:altIdentifier[@type='openn-url']/tei:idno")])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [openn_thumbnail])
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
