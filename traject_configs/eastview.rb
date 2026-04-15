# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/eastview'
require 'macros/field_extraction'
require 'macros/iiif'
require 'macros/jaraid'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/prepend'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/transformation'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::Eastview
extend Macros::FieldExtraction
extend Macros::IIIF
extend Macros::Jaraid
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Prepend
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
extend Macros::Transformation
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'allow_duplicate_values', false
  provide 'allow_nil_values', false
  provide 'allow_empty_fields', false
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
  provide 'log.batch_size', 100
end

# Load the map ONCE into RAM for M4 performance
@jaraid_map = Traject::TranslationMap.new('jaraid_from_eastview')

each_record do |record, context|
  f001_val = record['F001']
  if f001_val
    # Perform the lookup once and store result in clipboard
    context.clipboard[:jaraid_data] = @jaraid_map[f001_val]
  end
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

## File path
to_field 'dlme_source_file', path_to_file
to_field 'dlme_project', literal('dlme-serials')

to_field 'agg_data_provider_collection', literal('Eastview Middle East Serials'), lang('en')
to_field 'agg_data_provider_collection', literal('مسلسلات إيست فيو الشرق الأوسط'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('eastview-serials')

# CHO Required
to_field 'id', generate_eastview_issue_id('F001', 'issue-url')
to_field 'cho_title', extract_json('.issue-text'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')

# CLIPBOARD LOOKUP: cho_title_ja
to_field 'cho_title_ja' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  jaraid_title.call(data, accumulator, context) if data
end
to_field 'cho_title_ja', arabic_script_lang_or_default('und-Arab', 'en')

# CHO Other
to_field 'cho_contributor', extract_json('.F700'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_contributor', extract_json('.F710'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_creator', extract_with_fallback(['F100', 'F110', 'F700', 'F710']), flatten_array, dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')

# CLIPBOARD LOOKUP: cho_creator_ja
to_field 'cho_creator_ja' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  if data
    # Capture results in temp arrays to wrap in language hashes
    en_acc = []
    ar_acc = []
    jaraid_editors.call(data, en_acc, context)
    jaraid_editors_ar.call(data, ar_acc, context)

    accumulator.concat(en_acc.map { |v| { 'en' => v } })
    accumulator.concat(ar_acc.map { |v| { 'ar-Arab' => v } })
  end
end

# CLIPBOARD LOOKUP: cho_date (jaraid part)
to_field 'cho_date' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  jaraid_pub_dates.call(data, accumulator, context) if data
end
to_field 'cho_date', arabic_script_lang_or_default('und-Arab', 'en')

# this is the issue date we want
to_field 'cho_date', eastview_issue_date, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_date_range_norm', eastview_issue_date, dlme_strip, parse_range
to_field 'cho_date_range_hijri', eastview_issue_date, dlme_strip, parse_range, hijri_range
to_field 'cho_dc_rights', extract_json('.F506'), flatten_array, lang('en')
to_field 'cho_dc_rights', extract_json('.F540'), flatten_array, lang('en')
to_field 'cho_dc_rights', extract_json('.F542'), flatten_array, lang('en')
to_field 'cho_dc_rights', literal('Open Access to this collection is made possible through the generous support of the Center for Research Libraries and its member institutions.'), lang('en')

# CLIPBOARD LOOKUP: cho_description (jaraid part)
to_field 'cho_description' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  jaraid_notes('comment').call(data, accumulator, context) if data
end
to_field 'cho_description', arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_description', extract_json('.F520'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_description', extract_json('.F500'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_description', extract_json('.F490'), flatten_array, dlme_prepend('Series statement: '), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_description', extract_json('.F515'), flatten_array, dlme_prepend('Numbering Peculiarities Note: '), lang('en')

to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_json('.F300'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_has_type', literal('Serials'), lang('en')
to_field 'cho_has_type', literal('Serials'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_format', extract_json('.F336'), flatten_array, lang('en')
to_field 'cho_format', extract_json('.F337'), flatten_array, lang('en')

# CLIPBOARD LOOKUP: cho_identifier
to_field 'cho_identifier' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  accumulator.concat(Array(data)) if data
end
to_field 'cho_identifier', extract_json('.F001'), flatten_array
to_field 'cho_identifier', extract_json('.F035'), flatten_array
to_field 'cho_is_part_of', extract_json('.F830'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')

to_field 'cho_language', extract_with_fallback(['F041', ['F008', 35, 3]]), flatten_array, dlme_split(' '), dlme_strip, normalize_language, lang('en')
to_field 'cho_language', extract_with_fallback(['F041', ['F008', 35, 3]]), flatten_array, dlme_split(' '), dlme_strip, normalize_language, translation_map('lang_ar_from_en'), lang('ar-Arab')

# CLIPBOARD LOOKUP: cho_publisher
to_field 'cho_publisher' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  if data
    en_acc = []
    ar_acc = []
    jaraid_publishers.call(data, en_acc, context)
    jaraid_publishers_ar.call(data, ar_acc, context)

    accumulator.concat(en_acc.map { |v| { 'en' => v } })
    accumulator.concat(ar_acc.map { |v| { 'ar-Arab' => v } })
  end
end
to_field 'cho_publisher', extract_json('.F246'), flatten_array, dlme_gsub('880-02 ', ''), dlme_split(':'), at_index(1), dlme_strip, arabic_script_lang_or_default('und-Arab', 'en')

# CLIPBOARD LOOKUP: cho_spatial
to_field 'cho_spatial' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  if data
    en_acc = []
    ar_acc = []
    jaraid_pub_places.call(data, en_acc, context)
    jaraid_pub_places_ar.call(data, ar_acc, context)

    accumulator.concat(en_acc.map { |v| { 'en' => v } })
    accumulator.concat(ar_acc.map { |v| { 'ar-Arab' => v } })
  end
end

# CLIPBOARD LOOKUP: cho_spatial_coordinates
to_field 'cho_spatial_coordinates' do |_record, accumulator, context|
  data = context.clipboard[:jaraid_data]
  if data
    # Extract the intermediate place reference value
    place_refs = []
    jaraid_place_refs_from_id.call(data, place_refs, context)

    # Pass each found place_ref to the coordinate macro
    place_refs.each do |ref|
      jaraid_coordinates_from_pubplace.call(ref, accumulator, context)
    end
  end
end

to_field 'cho_subject', extract_json('.F610'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F650'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F651'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F653'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_subject', extract_json('.F655'), flatten_array, arabic_script_lang_or_default('und-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [extract_json('.issue-url')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context, 'wr_id' => [extract_json('.preview'), dlme_gsub('&width=600', '&width=400')])
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
  'cho_type',
  'agg_data_provider_collection'
)

each_record add_cho_type_facet
