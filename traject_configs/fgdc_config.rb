# frozen_string_literal: true

require 'traject_plus'
require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/fgdc'
require 'macros/post_process'

extend Macros::DateParsing
extend Macros::DLME
extend Macros::FGDC
extend Macros::PostProcess
extend TrajectPlus::Macros
extend TrajectPlus::Macros::FGDC
extend TrajectPlus::Macros::Xml

settings do
  provide 'writer_class_name', 'DlmeJsonResourceWriter'
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

# Record Identifier
to_field 'id', generate_fgdc_id(prefixed: true)

# CHO Required
to_field 'cho_identifier', generate_fgdc_id
to_field 'cho_title', extract_fgdc('/*/idinfo/citation/citeinfo/title')
to_field 'cho_title', extract_fgdc('/*/idinfo/citation/citeinfo/edition')

# CHO Other
to_field 'cho_coverage', extract_fgdc('/*/dataqual/lineage/srcinfo/srctime/timeinfo/rngdates/begdate')
to_field 'cho_coverage', extract_fgdc('/*/dataqual/lineage/srcinfo/srctime/timeinfo/rngdates/enddate')
to_field 'cho_coverage', extract_fgdc('/*/dataqual/lineage/srcinfo/srctime/timeinfo/sngdate/caldate')
# to_field 'cho_date', extract_fgdc('/*/dataqual/lineage/srcinfo/srccite/citeinfo/pubdate')
to_field 'cho_date', extract_fgdc('/*/idinfo/citation/citeinfo/pubdate')
to_field 'cho_date_range_norm', fgdc_date_range
to_field 'cho_date_range_hijri', fgdc_date_range, hijri_range
# to_field 'cho_dc_rights', extract_fgdc('/*/idinfo/accconst')
to_field 'cho_dc_rights', extract_fgdc('/*/idinfo/useconst')
to_field 'cho_description', extract_fgdc('/*/idinfo/descript/abstract')
to_field 'cho_description', extract_fgdc('/*/idinfo/descript/purpose')
to_field 'cho_description', extract_fgdc('/*/idinfo/status/update')
to_field 'cho_edm_type', literal('Image')
to_field 'cho_extent', extract_fgdc('/*/idinfo/crossref/citeinfo/othercit')
to_field 'cho_format', extract_fgdc('/*/distinfo/stdorder/digform/digtinfo/formname')
to_field 'cho_format', extract_fgdc('/*/spdoinfo/direct')
to_field 'cho_format', extract_fgdc('/*/spdoinfo/ptvctinf/sdtsterm/sdtstype')
to_field 'cho_format', extract_fgdc('/*/spdoinfo/rastinfo/rasttype')
to_field 'cho_type', extract_fgdc('/*/idinfo/citation/citeinfo/geoform')
to_field 'cho_type', extract_fgdc('/*/idinfo/crossref/citeinfo/geoform')
to_field 'cho_is_part_of', extract_fgdc('*/dataqual/lineage/srcinfo/srccite/citeinfo/lworkcit/citeinfo/serinfo/sername')
to_field 'cho_is_part_of', extract_fgdc('*/dataqual/lineage/srcinfo/srccite/citeinfo/lworkcit/citeinfo/title')
to_field 'cho_is_part_of', extract_fgdc('*/idinfo/citation/citeinfo/serinfo/sername')
to_field 'cho_provenance', extract_fgdc('/*/dataqual/lineage/procstep/proccont/cntinfo/cntorgp/cntorg')
to_field 'cho_provenance', extract_fgdc('/*/idinfo/citation/citeinfo/origin')
to_field 'cho_provenance', extract_fgdc('/*/idinfo/crossref/citeinfo/origin')
to_field 'cho_provenance', extract_fgdc('/*/idinfo/native')
to_field 'cho_publisher', extract_fgdc('/*/idinfo/citation/citeinfo/pubinfo/publish')
to_field 'cho_publisher', extract_fgdc('/*/idinfo/crossref/citeinfo/pubinfo/publish')
to_field 'cho_publisher', extract_fgdc('/*/distinfo/distrib/cntinfo/cntorgp/cntorg')
to_field 'cho_publisher', extract_fgdc('/*/distinfo/distrib/cntinfo/cntpos')
to_field 'cho_source', extract_fgdc('/*/dataqual/lineage/procstep/srcprod')
to_field 'cho_source', extract_fgdc('/*/dataqual/lineage/procstep/srcused')
to_field 'cho_source', extract_fgdc('/*/dataqual/lineage/srcinfo/srccite/citeinfo/origin')
to_field 'cho_source', extract_fgdc('/*/dataqual/lineage/srcinfo/srccite/citeinfo/pubinfo/publish')
to_field 'cho_source', extract_fgdc('/*/dataqual/lineage/srcinfo/srccite/citeinfo/serinfo/issue')
to_field 'cho_source', extract_fgdc('/*/dataqual/lineage/srcinfo/srccite/citeinfo/serinfo/sername')
to_field 'cho_source', extract_fgdc('/*/dataqual/lineage/srcinfo/srccite/citeinfo/title')
to_field 'cho_spatial', extract_fgdc('/*/idinfo/keywords/place/placekey')
to_field 'cho_spatial', extract_fgdc('/*/idinfo/spdom/bounding/eastbc')
to_field 'cho_spatial', extract_fgdc('/*/idinfo/spdom/bounding/northbc')
to_field 'cho_spatial', extract_fgdc('/*/idinfo/spdom/bounding/southbc')
to_field 'cho_spatial', extract_fgdc('/*/idinfo/spdom/bounding/westbc')
to_field 'cho_type', extract_fgdc('/*/dataqual/lineage/srcinfo/srccite/citeinfo/geoform')

# Aggregation Object(s)

# Using settings for agg_provider and agg_data_provider for the time being.
to_field 'agg_provider', provider, lang('en')
to_field 'agg_provider', provider_ar, lang('ar-Arab')
to_field 'agg_data_provider', data_provider, lang('en')
to_field 'agg_data_provider', data_provider_ar, lang('ar-Arab')

to_field 'agg_is_shown_at' do |record, accumulator, context|
  accumulator << transform_values(context,
                                  'wr_id' => literal(record.xpath('/*/idinfo/citation/citeinfo/onlink', NS)
                                             .map(&:text)
                                             .first
                                             .split('VCollName=')
                                             .last
                                             .downcase
                                             .tr('_', '-')
                                             .prepend('https://earthworks.stanford.edu/catalog/harvard-')),
                                  'wr_dc_rights' => extract_fgdc('/*/idinfo/useconst'))
end

to_field 'agg_provider_country', provider_country, lang('en')
to_field 'agg_provider_country', provider_country_ar, lang('ar-Arab')
to_field 'agg_data_provider_country', data_provider_country, lang('en')
to_field 'agg_data_provider_country', data_provider_country_ar, lang('ar-Arab')

each_record convert_to_language_hash('agg_data_provider', 'agg_data_provider_country', 'agg_provider', 'agg_provider_country', 'cho_title', 'cho_description')

# Not using agg_is_shown_at
# Not using agg_is_shown_by
# Not using agg_preview

# Service Objects
# No known services from Harvard FGDC.
