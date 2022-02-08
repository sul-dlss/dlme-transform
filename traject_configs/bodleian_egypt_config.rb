# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'dlme_debug_writer'
require 'macros/collection'
require 'macros/dlme'
require 'macros/each_record'

extend Macros::Collection
extend Macros::DLME
extend Macros::EachRecord
extend TrajectPlus::Macros
extend TrajectPlus::Macros::Csv

settings do
  provide 'reader_class_name', 'TrajectPlus::CsvReader'
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
end

to_field 'agg_data_provider_collection', literal('Exploring Egypt in the 19th Century (Bodleian Library)'), lang('en')
to_field 'agg_data_provider_collection', literal('Exploring Egypt in the 19th Century (Bodleian Library)'), translation_map('agg_collection_ar_from_en'), lang('ar-Arab')
to_field 'agg_data_provider_collection_id', literal('bodleian_exploring_egypt')

to_field 'cho_has_type', literal('Books'), lang('en')
to_field 'cho_has_type', literal('Books'), translation_map('has_type_ar_from_en'), lang('ar-Arab')

each_record convert_to_language_hash(
  'agg_data_provider_collection',
  'cho_has_type'
)
