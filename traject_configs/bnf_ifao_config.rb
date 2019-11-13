# frozen_string_literal: true

to_field 'cho_contributor', extract_srw('dc:contributor'), strip # split('.'), first_only, strip
to_field 'cho_creator', extract_srw('dc:creator'), split('.'), first_only, strip
to_field 'cho_creator', extract_srw('dc:creator[2]'), split('.'), first_only, strip
to_field 'cho_creator', extract_srw('dc:creator[3]'), split('.'), first_only, strip
to_field 'cho_edm_type', extract_srw('dc:type'),
         default('notated music'), first_only, strip, transform(&:downcase), translation_map('not_found', 'types', 'french-types')
to_field 'cho_language', extract_srw('dc:language'), first_only, strip, translation_map('marc_languages')

# NOTE: compute cho_type_facet BEFORE calling convert_to_language_hash fields
# NOTE: do *not* include cho_type_facet in convert_to_language_hash fields
each_record add_cho_type_facet

each_record convert_to_language_hash(
  'cho_contributor',
  'cho_creator',
  'cho_edm_type',
  'cho_language'
)
