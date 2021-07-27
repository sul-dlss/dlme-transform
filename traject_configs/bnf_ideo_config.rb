# frozen_string_literal: true

# Cho Required
to_field 'cho_title', extract_srw('dc:title[1]'), strip, lang('ar-Arab')
to_field 'cho_title', extract_srw('dc:title[2]'), strip, lang('ar-Latn')

# Cho Other
to_field 'cho_contributor', extract_srw('dc:contributor'), split('. '), first_only, strip, lang('und-Latn')
to_field 'cho_contributor', extract_srw('dc:contributor[2]'), strip, gsub(/. Fonction indéterminée/, ''), lang('und-Latn')
to_field 'cho_creator', extract_srw('dc:creator'), split('. '), first_only, strip, lang('und-Latn')
to_field 'cho_creator', extract_srw('dc:creator[2]'), strip, gsub(/. Fonction indéterminée/, ''), lang('und-Latn')
to_field 'cho_edm_type', literal('Text'), lang('en')
to_field 'cho_edm_type', literal('Text'), translation_map('edm_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_has_type', literal('Books'), lang('en')
to_field 'cho_has_type', literal('Books'), translation_map('has_type_ar_from_en'), lang('ar-Arab')
to_field 'cho_publisher', extract_srw('dc:publisher[1]'), strip, lang('ar-Latn')
to_field 'cho_publisher', extract_srw('dc:publisher[2]'), strip, lang('ar-Arab')
to_field 'cho_subject', extract_srw('dc:subject'), strip, lang('und-Latn')
to_field 'cho_type', extract_srw('dc:type'), lang('fr')

each_record convert_to_language_hash(
  'cho_contributor',
  'cho_creator',
  'cho_edm_type',
  'cho_has_type',
  'cho_publisher',
  'cho_subject',
  'cho_title',
  'cho_type'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
