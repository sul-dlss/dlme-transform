# frozen_string_literal: true

# Cho Required
to_field 'cho_title', extract_srw('dc:title'), strip, lang('fr')

# Cho Other
to_field 'cho_contributor', extract_srw('dc:contributor'), strip # split('.'), first_only, strip
to_field 'cho_creator', extract_srw('dc:creator'), split('.'), first_only, strip
to_field 'cho_creator', extract_srw('dc:creator[2]'), split('.'), first_only, strip
to_field 'cho_creator', extract_srw('dc:creator[3]'), split('.'), first_only, strip
to_field 'cho_edm_type', extract_srw('dc:type'), first_only, strip, normalize_type, lang('en')
to_field 'cho_edm_type', extract_srw('dc:type'), first_only, strip, normalize_type, translation_map('norm_types_to_ar'), lang('ar-Arab')
to_field 'cho_has_type', extract_srw('dc:type[1]'),
         gsub('image fixe', 'Photograph'),
         gsub('text', 'Book'),
         gsub('manuscript', 'Manuscript'),
         lang('en')
to_field 'cho_has_type', extract_srw('dc:type[1]'),
        gsub('image fixe', 'Photograph'),
        gsub('text', 'Book'),
        gsub('manuscript', 'Manuscript'),
        translation_map('norm_has_type_to_ar'),
        lang('ar-Arab')
to_field 'cho_publisher', extract_srw('dc:publisher'), strip, lang('fr')
to_field 'cho_subject', extract_srw('dc:subject'), strip, lang('fr')
to_field 'cho_type', extract_srw('dc:type')

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
