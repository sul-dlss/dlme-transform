# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
require 'macros/harvard_ihp'
require 'macros/language_extraction'
require 'macros/mods'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::FieldExtraction
extend Macros::HarvardIHP
extend Macros::LanguageExtraction
extend Macros::Mods
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Mods
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file

# Cho Required
to_field 'id', generate_mods_id
to_field 'cho_title', ihp_uniform_title, strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_title', extract_mods('//*/mods:titleInfo[@type="uniform"][2]/mods:title'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')

# Cho Other
to_field 'cho_alternative', extract_mods('//*/mods:titleInfo[@type="alternative"]/mods:title'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', role: 'copyist.'), gsub('copyist.', 'copyist'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_contributor', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', role: 'scribe.'), gsub('scribe.', 'scribe'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_creator', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', role: 'cre'), gsub('cre', 'creator'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_creator', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', role: 'creator'), strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_date', extract_mods('//*/mods:originInfo/mods:dateCreated'), prepend('Date Created: '), strip, lang('en')
to_field 'cho_date', extract_mods('//*/mods:originInfo/mods:dateValid'), prepend('Date Valid: '), strip, lang('en')
to_field 'cho_date', extract_mods('//*/mods:originInfo/mods:dateIssued[1]'), prepend('Date Issued: '), strip, lang('en')
to_field 'cho_date_range_norm', ihp_date_range
to_field 'cho_date_range_hijri', ihp_date_range, hijri_range
to_field 'cho_description', extract_mods('//*/mods:abstract'), lang('und-Latn')
to_field 'cho_description', extract_mods('//*/mods:note'), lang('und-Latn')
to_field 'cho_description', extract_mods('//*/mods:tableOfContents'), prepend('Table of Contents: '), lang('und-Latn')
to_field 'cho_edm_type', extract_mods('//*/mods:typeOfResource'), translation_map('types'), lang('en')
to_field 'cho_edm_type', extract_mods('//*/mods:typeOfResource'), translation_map('types'), translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_extent', extract_mods('//*/mods:physicalDescription/mods:extent'), lang('ar-Arab')
to_field 'cho_has_type', extract_mods('//*/mods:genre[1]'), ihp_has_type, lang('en')
to_field 'cho_has_type', extract_mods('//*/mods:genre[1]'), ihp_has_type, translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_is_part_of', extract_mods('//*/mods:relatedItem[@type="series"]/mods:titleInfo'), gsub('UniversityIslamic', 'University Islamic'), lang('en')
to_field 'cho_identifier', extract_mods('//*/mods:recordInfo/mods:recordIdentifier')
to_field 'cho_language', extract_mods('//*/mods:language/mods:languageTerm[1]'), normalize_language, lang('en')
to_field 'cho_language', extract_mods('//*/mods:language/mods:languageTerm[1]'), normalize_language, translation_map('norm_languages_to_ar'), lang('ar-Arab')
to_field 'cho_provenance', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', role: 'former owner.'), gsub('former owner.', 'former owner'), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_provenance', extract_name('//*/mods:name[2][mods:role/mods:roleTerm/', role: 'former owner.'), gsub('former owner.', 'former owner'), gsub('former owner', 'مالك سابق'), arabic_script_lang_or_default('und-Arab', 'und-Latn')
to_field 'cho_publisher', extract_mods('//*/mods:originInfo/mods:publisher'), lang('en')
to_field 'cho_spatial', xpath_multi_lingual_commas_with_prepend('//*/mods:originInfo/mods:place/mods:placeTerm', 'مكان الإنتاج: ', 'Place of Production: '), gsub(' :', ''), arabic_script_lang_or_default('und-Arab', 'en')
to_field 'cho_spatial', extract_mods('//*/mods:subject/mods:geographic'), lang('en')
to_field 'cho_subject', extract_mods('//*/mods:subject/mods:topic'), lang('en')
to_field 'cho_temporal', extract_mods('//*/mods:subject/mods:temporal'), lang('en')
to_field 'cho_type', extract_mods('//*/mods:typeOfResource'), lang('en')
to_field 'cho_type', extract_mods('//*/mods:genre'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_mods('//*/mods:location/mods:url[@access="raw object"]')],
    'wr_is_referenced_by' => [extract_ihp_manifest]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_mods('//*/mods:location/mods:url[@access="preview"]'), gsub('full/,150/0', 'full/400,400/0'), strip],
    'wr_is_referenced_by' => [extract_ihp_manifest]
  )
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
