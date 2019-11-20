# frozen_string_literal: true

# Cho Other
to_field 'cho_contributor', extract_json('.contributor'), strip, lang('ar-Arab')

each_record convert_to_language_hash(
  'cho_contributor'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
