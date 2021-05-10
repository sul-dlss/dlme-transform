# frozen_string_literal: true

# Cho Required
to_field 'cho_title', extract_oai('dc:title'), strip, lang('ar-Arab')

# Cho Other
to_field 'cho_contributor', extract_oai('dc:contributor'),
         strip, split('.'), lang('ar-Arab')
to_field 'cho_creator', extract_oai('dc:creator'),
         strip, split('.'), lang('ar-Arab')
to_field 'cho_dc_rights', extract_oai('dc:rights'), strip, lang('ar-Arab')
to_field 'cho_description', extract_oai('dc:description'), strip, lang('ar-Arab')
to_field 'cho_has_type', literal('Periodical'), lang('en')
to_field 'cho_has_type', literal('Periodical'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_is_part_of', extract_oai('dc:source'), strip, lang('ar-Arab')
to_field 'cho_publisher', literal('Dar al-Adab'), lang('en')
to_field 'cho_publisher', literal('دار الأدب'), lang('ar-Arab')
to_field 'cho_subject', extract_oai('dc:subject'), strip, lang('ar-Arab')

each_record convert_to_language_hash(
  'cho_contributor',
  'cho_creator',
  'cho_dc_rights',
  'cho_description',
  'cho_has_type',
  'cho_is_part_of',
  'cho_publisher',
  'cho_subject',
  'cho_title'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
