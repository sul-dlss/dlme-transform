# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'macros/language_extraction'
require 'macros/normalize_language'
require 'macros/normalize_type'
require 'macros/path_to_file'
require 'macros/string_helper'
require 'macros/timestamp'
require 'macros/title_extraction'
require 'macros/version'
require 'traject_plus'

extend Macros::Collection
extend Macros::DLME
extend Macros::DateParsing
extend Macros::EachRecord
extend Macros::LanguageExtraction
extend Macros::NormalizeLanguage
extend Macros::NormalizeType
extend Macros::PathToFile
extend Macros::StringHelper
extend Macros::Timestamp
extend Macros::TitleExtraction
extend Macros::Version
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Set Version & Timestamp on each record
to_field 'transform_version', version
to_field 'transform_timestamp', timestamp

# File path
to_field 'dlme_source_file', path_to_file


### Tests
# test-null: calling split on null values raises an error
# to_field 'cho_creator', extract_json('..creator'), flatten_array, split('::'), strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# However nil_tests/dlme_split works
require 'macros/nil_tests'
extend Macros::Split
to_field 'cho_creator', extract_json('..creator'), flatten_array, dlme_split('::'), lang('en')
# But the arabic_script_lang_or_default macro fails
to_field 'cho_creator', extract_json('..creator'), flatten_array, dlme_split('::'), arabic_script_lang_or_default('und-Arab', 'en')

# test-null: calling strip on null values raises an error
# to_field 'cho_title', extract_json('..uniform-title'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')

# test-null: calling prepend on null values raises an error
# to_field 'cho_provenance', extract_json('..owner'), flatten_array, prepend('Owner: '), arabic_script_lang_or_default('ar-Arab', 'en')

# test-array: calling split on an array gets the correct number of values and splits them as expected
# to_field 'cho_creator', extract_json('..creator'), flatten_array, split('::'), strip, unique, arabic_script_lang_or_default('und-Arab', 'en')

# test-array: calling strip on an array raises an error
# to_field 'cho_title', extract_json('..uniform-title'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')

# test-array: calling prepend on an array gets the correct number of values and prepends to each of them
# to_field 'cho_is_part_of', extract_json('..member-of-collections'), flatten_array, prepend('Collection: '), lang('en')

### End Tests

to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('agg_collection_from_provider_id'), lang('en')
to_field 'agg_data_provider_collection', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('agg_collection_from_provider_id'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-')

# Cho Required
to_field 'id', extract_json('.id'), split('/'), at_index(-2), strip, unique
to_field 'cho_title', extract_json('..title'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# test-null: calling strip on null values raises an error
# to_field 'cho_title', extract_json('..uniform-title'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')

# Cho Other
# to_field 'cho_alternative', extract_json('..alternative'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_creator', extract_json('..author'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_creator', extract_json('..creator'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..artist'), flatten_array, strip, unique, prepend('Artist: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..abridger'), flatten_array, strip, unique, prepend('Abridger: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..annotator'), flatten_array, strip, unique, prepend('Annotator: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..calligrapher'), flatten_array, strip, unique, prepend('Calligrapher: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..compiler'), flatten_array, strip, unique, prepend('Compiler: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..contributor'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..director'), flatten_array, strip, unique, prepend('Director: '), arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_contributor', extract_json('..rendered-actors'), flatten_array, strip, unique, prepend('Actor: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..scribe'), flatten_array, strip, unique, prepend('Scribe: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_contributor', extract_json('..translator'), flatten_array, strip, unique, prepend('Translator: '), arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_date', extract_json('..date'), flatten_array, strip, unique, arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_date_range_norm', extract_json('..date'), flatten_array, strip, unique, parse_range
# to_field 'cho_date_range_hijri', extract_json('..date'), flatten_array, strip, unique, parse_range, hijri_range
# to_field 'cho_date', extract_json('..date-created'), flatten_array, strip, unique, arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_date_range_norm', extract_json('..date-created'), flatten_array, strip, unique, parse_range
# to_field 'cho_date_range_hijri', extract_json('..date-created'), flatten_array, strip, unique, parse_range, hijri_range
# to_field 'cho_dc_rights', literal('https://rbsc.princeton.edu/services/imaging-publication-services'), arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_description', extract_json('..abstract'), flatten_array, strip, unique, prepend('Abstract: '), arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_description', extract_json('..binding-note'), flatten_array, strip, unique, prepend('Binding note: '), arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_description', extract_json('..contents'), flatten_array, strip, unique, prepend('Contents: '), arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_description', extract_json('..description'), flatten_array, strip, unique, lang('en')
# to_field 'cho_edm_type', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('has_type_from_collection'), translation_map('edm_type_from_has_type'), unique, lang('en')
# to_field 'cho_edm_type', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('has_type_from_collection'), translation_map('edm_type_from_has_type'), translation_map('edm_type_ar_from_en'), unique, lang('ar-Arab')
# to_field 'cho_extent', extract_json('..extent'), flatten_array, strip, unique, lang('en')
# to_field 'cho_has_type', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('has_type_from_collection'), unique, lang('en')
# to_field 'cho_has_type', path_to_file, split('/'), at_index(2), gsub('_', '-'), prepend('princeton-'), translation_map('has_type_from_collection'), translation_map('has_type_ar_from_en'), unique, lang('ar-Arab')
# to_field 'cho_identifier', extract_json('..call-number'), flatten_array, strip
# to_field 'cho_identifier', extract_json('..identifier'), flatten_array, strip
# to_field 'cho_identifier', extract_json('..local-identifier'), flatten_array, strip
# to_field 'cho_identifier', extract_json('..replaces'), flatten_array, strip, unique, prepend('Replaces: ')
# to_field 'cho_is_part_of', extract_json('..member-of-collections'), flatten_array, strip, unique, lang('en')
# # Leaving out the 'text-language' column because its mostly redundant.
# to_field 'cho_language', extract_json('..language'), flatten_array, strip, normalize_language, unique, lang('en')
# to_field 'cho_language', extract_json('..language'), flatten_array, strip, normalize_language, translation_map('lang_ar_from_en'), unique, lang('ar-Arab')
# to_field 'cho_provenance', extract_json('..collector'), prepend('Collector: [0]'), flatten_array, strip, unique, arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_provenance', extract_json('..former-owner'), prepend('Former owner: [0]'), flatten_array, strip, unique, arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_provenance', extract_json('..provenance'), flatten_array, strip, unique, arabic_script_lang_or_default('ar-Arab', 'en')
# to_field 'cho_publisher', extract_json('..publisher'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_spatial', extract_json('..geographic-origin'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_subject', extract_json('..genre'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_subject', extract_json('..subject'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_type', extract_json('..resource-type'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')
# to_field 'cho_type', extract_json('..type'), flatten_array, strip, unique, arabic_script_lang_or_default('und-Arab', 'en')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.identifier[0]'), split("Identifier'>"), last, split('</a>'), first_only, strip],
                                  'wr_is_referenced_by' => extract_json('.id'))
end
# One record is missing 'thumbnail' value. To get around that, we pass a generic thumnail image to `default`.
# This should be removed once Princeton fixes the data issue.
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => [extract_json('.thumbnail[0]'), first_only, split('/full/'), strip, append('/full/!400,400/0/default.jpg'), default('https://iiif-cloud.princeton.edu/iiif/2/ce%2Fa3%2F3e%2Fcea33ed8c16141de94a3414f38290306%2Fintermediate_file/full/!400,400/0/default.jpg')],
                                  'wr_is_referenced_by' => extract_json('.id'))
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

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
