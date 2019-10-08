# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'macros/dlme'
require 'macros/post_process'

extend Macros::DLME
extend Macros::PostProcess
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::JsonReader'
end

# Cho Required
to_field 'id', extract_json('.thumbnail'),
         strip,
         gsub('/full/256,/0/default.jpg', ''),
         gsub('https://iiif.bodleian.ox.ac.uk/iiif/image/', '')
to_field 'cho_title', extract_json('.title'), strip, default('Untitled Item')

# Cho Other
to_field 'cho_creator', extract_json('.author'), strip
to_field 'cho_contributor', extract_json('.printer'), strip, append(' [printer]')
to_field 'cho_date', extract_json('.date_statement'), strip
to_field 'cho_date_range_norm', extract_json('.date_statement'), strip
to_field 'cho_dc_rights', literal('Photo: © Bodleian Libraries, University of Oxford, Terms of use: http://digital.bodleian.ox.ac.uk/terms.html')
to_field 'cho_description', extract_json('.description'), strip
to_field 'cho_edm_type', literal('Text')
to_field 'cho_spatial', extract_json('.place_of_origin'), strip, prepend('Place of Origin: ')
to_field 'cho_language', extract_json('.language'), strip, transform(&:downcase), translation_map('not_found', 'languages')

# Agg
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_is_shown_at' do |_record, accumulator, context|
  accumulator << transform_values(
    context,
    'wr_id' => [extract_json('.homepage'), strip]
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
