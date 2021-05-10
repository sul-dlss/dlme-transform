# frozen_string_literal: true

# Cho Required
to_field 'cho_title', extract_oai('dc:title'), strip, lang('en')

# Cho Other
to_field 'cho_dc_rights', extract_oai('dc:rights'), strip, lang('en')
to_field 'cho_description', extract_oai('dc:description'), strip, lang('en')
to_field 'cho_has_type', literal('Book'), lang('en')
to_field 'cho_has_type', literal('Book'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_subject', extract_oai('dc:subject'), strip

each_record convert_to_language_hash(
  'cho_contributor',
  'cho_dc_rights',
  'cho_description',
  'cho_has_type',
  'cho_spatial',
  'cho_subject',
  'cho_title'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
