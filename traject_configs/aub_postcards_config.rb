# frozen_string_literal: true

# Cho Required
to_field 'cho_title', extract_oai('dc:title'), strip

# Cho Other
to_field 'cho_contributor', extract_oai('dc:contributor'),
         strip, split('.'), lang('en')
to_field 'cho_dc_rights', extract_oai('dc:rights'), strip, lang('en')
to_field 'cho_description', extract_oai('dc:description'), strip, lang('en')
to_field 'cho_has_type', literal('Postcard'), lang('en')
to_field 'cho_has_type', literal('Postcard'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_subject', extract_oai('dc:subject'), strip, lang('en')

# NOTE: compute cho_type_facet BEFORE calling convert_to_language_hash fields
# NOTE: do *not* include cho_type_facet in convert_to_language_hash fields
each_record add_cho_type_facet

each_record convert_to_language_hash(
  'cho_contributor',
  'cho_dc_rights',
  'cho_description',
  'cho_has_type',
  'cho_subject',
  'cho_title'
)
