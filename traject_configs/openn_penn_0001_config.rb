# frozen_string_literal: true

# CHO other
to_field 'cho_creator', extract_tei("#{MS_DESC}/#{MS_CONTENTS}/#{MS_ITEM}/tei:author"), strip

each_record convert_to_language_hash(
  'cho_creator'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
