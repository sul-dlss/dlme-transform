# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/harvard_scw'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/field_extraction'
require 'macros/mods'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend Macros::FieldExtraction
extend Macros::HarvardSCW
extend Macros::Mods
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::Timestamp
extend Macros::TitleExtraction
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

# CHO Required
to_field 'id', generate_mods_id
# Both titles need the same langauge value
to_field 'cho_title', extract_mods('/*/mods:titleInfo[1]/mods:title'), prepend('Main Title: '), lang('und-Latn')
to_field 'cho_title', xpath_title_plus('/*/mods:relatedItem[@type="constituent"]/mods:titleInfo/mods:title', '/*/mods:relatedItem/mods:recordInfo/mods:recordIdentifier'), prepend('Image Title: '), lang('und-Latn')

# CHO Other
to_field 'cho_alternative', extract_mods('/*/mods:titleInfo[@type="alternative"]/mods:title'), lang('en')
to_field 'cho_creator', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'artist'), lang('en')
to_field 'cho_creator', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'author'), lang('en')
to_field 'cho_creator', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'calligrapher'), lang('en')
to_field 'cho_creator', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'copyist'), lang('en')
to_field 'cho_creator', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'illuminator'), lang('en')
to_field 'cho_creator', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'illustrator'), lang('en')
to_field 'cho_creator', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'painter (artist)'), gsub('painter (artist)', '(painter)'), lang('en')
to_field 'cho_date', extract_mods('/*/mods:originInfo/mods:dateCreated'), lang('en')
to_field 'cho_date_range_norm', mods_date_range
to_field 'cho_date_range_hijri', mods_date_range, hijri_range
to_field 'cho_dc_rights', literal('(CC BY-NC-SA) Attribution: Harvard Fine Arts Library, Special Collections SCW2016.07911'), lang('en')
to_field 'cho_description', extract_mods('/*/mods:abstract'), lang('en')
to_field 'cho_description', xpath_commas_with_prepend('/*/mods:extension/cdwalite:cultureWrap/cdwalite:culture', 'Culture: '), lang('en')
to_field 'cho_description', xpath_commas_with_prepend('/*/mods:extension/cdwalite:indexingMaterialsTechSet/cdwalite:termMaterialsTech', 'Materials/Techniques: '), transform(&:downcase), gsub('materials/techniques:', 'Materials/Techniques:'), lang('en')
to_field 'cho_description', extract_mods('/*/mods:note'), prepend('Note: '), lang('en')
to_field 'cho_edm_type', scw_has_type, normalize_has_type, normalize_edm_type, lang('en')
to_field 'cho_edm_type', scw_has_type, normalize_has_type, normalize_edm_type, translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_extent', extract_mods('/*/mods:physicalDescription/mods:extent'), lang('en')
to_field 'cho_has_type', scw_has_type, normalize_has_type, lang('en')
to_field 'cho_has_type', scw_has_type, normalize_has_type, translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_is_part_of', literal('Stuart Cary Welch Islamic and South Asian Photographic Collection'), lang('en')
to_field 'cho_identifier', extract_mods('/*/mods:recordInfo/mods:recordIdentifier')
to_field 'cho_provenance', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'former owner'), lang('en')
to_field 'cho_provenance', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'former repository'), lang('en')
to_field 'cho_provenance', extract_name('/*/mods:name[mods:role/mods:roleTerm/', role: 'patron'), lang('en')
to_field 'cho_spatial', extract_mods('/*/mods:originInfo/mods:place/mods:placeTerm'), prepend('Place of Production: '), lang('en')
to_field 'cho_spatial', extract_mods('/*/mods:subject/mods:geographic'), lang('en')
to_field 'cho_subject', extract_mods('/*/mods:subject/mods:topic'), lang('en')
to_field 'cho_type', extract_mods('/*/mods:typeOfResource'), lang('en')
to_field 'cho_type', extract_mods('/*/mods:genre'), lang('en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_data_provider_collection', collection
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_dc_rights' => [literal('(CC BY-NC-SA) Attribution: Harvard Fine Arts Library, Special Collections SCW2016.07911')],
                                  'wr_edm_rights' => [literal('CC BY-NC-SA: http://creativecommons.org/licenses/by-nc-sa/4.0/')],
                                  'wr_id' => [extract_mods('/*/mods:relatedItem[@otherType="HOLLIS Images record"]/mods:location/mods:url'), strip],
                                  'wr_is_referenced_by' => [extract_harvard('/*/mods:extension/HarvardDRS:DRSMetadata/HarvardDRS:drsFileId'), prepend('https://iiif.lib.harvard.edu/manifests/ids:')])
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_dc_rights' => [literal('(CC BY-NC-SA) Attribution: Harvard Fine Arts Library, Special Collections SCW2016.07911')],
                                  'wr_edm_rights' => [literal('CC BY-NC-SA: http://creativecommons.org/licenses/by-nc-sa/4.0/')],
                                  'wr_id' => [extract_mods('/*/mods:relatedItem[@type="constituent"]/mods:location/mods:url[@displayLabel="Thumbnail"]'), strip, gsub('width=150', 'width=400'), gsub('height=150', 'height=400')],
                                  'wr_is_referenced_by' => [extract_harvard('/*/mods:extension/HarvardDRS:DRSMetadata/HarvardDRS:drsFileId'), prepend('https://iiif.lib.harvard.edu/manifests/ids:')])
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
