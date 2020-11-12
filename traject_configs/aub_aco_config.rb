# frozen_string_literal: true

# Cho Required
to_field 'cho_title', xpath_title_or_desc("#{OAI_PREFIX}/dc:title", "#{OAI_PREFIX}/dc:description[1]"), arabic_or_und_latn, default('Untitled', 'بدون عنوان')

# Cho Other
to_field 'cho_contributor', extract_oai('dc:contributor'),
         strip, split('.'), lang('en')
to_field 'cho_creator', extract_oai('dc:creator'), strip
to_field 'cho_description', extract_oai('dc:description'), strip, lang('ar-Arab')
to_field 'cho_has_type', literal('Book'), lang('en')
to_field 'cho_has_type', literal('Book'), translation_map('norm_has_type_to_ar'), lang('ar-Arab')
to_field 'cho_subject', extract_oai('dc:subject'), strip

each_record convert_to_language_hash(
  'cho_creator',
  'cho_description',
  'cho_has_type',
  'cho_subject',
  'cho_title'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
