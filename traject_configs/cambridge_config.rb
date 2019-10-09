# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'macros/dlme'
require 'macros/tei'
require 'macros/post_process'

extend Macros::PostProcess
extend Macros::DLME
extend Macros::Tei
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Xml
extend TrajectPlus::Macros::Tei

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Shortcut variables
ms_desc = '/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc'
ms_contents = 'tei:msContents'
ms_id = 'tei:msIdentifier'
ms_item = 'tei:msItem'
ms_origin = 'tei:history/tei:origin'
obj_desc = 'tei:physDesc/tei:objectDesc'
profile_desc = '/*/tei:teiHeader/tei:profileDesc/tei:textClass'
pub_stmt = '/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt'
support_desc = 'tei:supportDesc[@material="paper"]'
facsimile = '/*/tei:facsimile'

# Cho Required
to_field 'id', lambda { |_record, accumulator, context|
  bare_id = default_identifier(context)
  accumulator << identifier_with_prefix(context, bare_id)
}
to_field 'cho_title', extract_tei("#{ms_desc}/#{ms_contents}/#{ms_item}/tei:title[1]")

# Cho other
to_field 'cho_creator', extract_tei("#{ms_desc}/#{ms_contents}/#{ms_item}/tei:author")
to_field 'cho_date', extract_tei("#{ms_desc}/#{ms_origin}/tei:origDate"), strip
# to_field 'cho_date_range_norm', extract_tei("#{ms_desc}/#{ms_origin}/tei:origDate"), strip
to_field 'cho_dc_rights', extract_tei("#{pub_stmt}/tei:availability/tei:licence"), strip
to_field 'cho_description', extract_tei("#{ms_desc}/#{ms_contents}/tei:summary")
to_field 'cho_edm_type', literal('Text')
to_field 'cho_extent', extract_tei("#{ms_desc}/#{obj_desc}/#{support_desc}/tei:extent")
to_field 'cho_identifier', extract_tei("#{ms_desc}/#{ms_id}/tei:idno[@type='call-number']"), strip
to_field 'cho_language', extract_tei("#{ms_desc}/#{ms_contents}/#{ms_item}/tei:textLang/@mainLang"), transform(&:downcase),
         translation_map('not_found',
                         'languages',
                         'marc_languages',
                         'iso_639-2',
                         'iso_639-3')
to_field 'cho_language', extract_tei("#{ms_desc}/#{ms_contents}/#{ms_item}/tei:textLang/@otherLangs"), split(' '), transform(&:downcase),
         translation_map('not_found',
                         'languages',
                         'iso_639-2',
                         'iso_639-3')
to_field 'cho_provenance', extract_tei("#{ms_desc}/tei:history/tei:provenance")
to_field 'cho_publisher', extract_tei("#{pub_stmt}/tei:publisher"), strip
to_field 'cho_spatial', extract_tei("#{ms_desc}/#{ms_origin}/tei:origPlace")
to_field 'cho_subject', extract_tei("#{profile_desc}/tei:keywords[@n='form/genre']/tei:term")
to_field 'cho_subject', extract_tei("#{profile_desc}/tei:keywords[@n='subjects']/tei:term")

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_tei("#{facsimile}/tei:graphic/@url"),
                                              gsub('http://cudl.lib.cam.ac.uk/content/images/', 'https://cudl.lib.cam.ac.uk/view/'),
                                              gsub('-000-0000', '/'),
                                              gsub('_files/8/0_0.jpg', '')])
end
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_tei("#{facsimile}/tei:graphic/@url"), gsub('http://', 'https://image01.')])
end

to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash('agg_data_provider', 'agg_data_provider_country', 'agg_provider', 'agg_provider_country', 'cho_title')
