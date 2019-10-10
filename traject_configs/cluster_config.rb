# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'macros/dlme'
require 'macros/date_parsing'
require 'macros/post_process'

extend Macros::PostProcess
extend Macros::DLME
extend Macros::DateParsing
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Cho Required
to_field 'id', extract_json('.url'), strip
to_field 'cho_title', extract_json('.title'), strip

# Cho Other
to_field 'cho_creator', extract_json('.creator'), strip
to_field 'cho_contributor', extract_json('.contributor'), strip
to_field 'cho_date', extract_json('.date'), strip
to_field 'cho_date_range_norm', extract_json('.date'), strip, range_array_from_positive_4digits_hyphen
to_field 'cho_date_range_hijri', extract_json('.date'), strip, range_array_from_positive_4digits_hyphen, hijri_range
to_field 'cho_description', extract_json('.description'), strip
to_field 'cho_edm_type', literal('Dataset')
to_field 'cho_language', literal('English')
to_field 'cho_language', literal('Arabic')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.url'), strip]
  )
end
to_field 'agg_preview' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.thumbnail'), strip]
  )
end

to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash('agg_data_provider', 'agg_data_provider_country', 'agg_provider', 'agg_provider_country', 'cho_title')
