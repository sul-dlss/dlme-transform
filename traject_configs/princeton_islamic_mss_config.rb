# frozen_string_literal: true

require 'dlme_json_resource_writer'
require 'macros/date_parsing'
require 'macros/dlme'
require 'macros/each_record'
require 'traject_plus'

extend Macros::DateParsing
extend Macros::DLME
extend Macros::EachRecord
extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON

# Cho Other
to_field 'cho_contributor', extract_json('.contributor'), strip

each_record convert_to_language_hash(
  'cho_contributor'
)

# NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
each_record add_cho_type_facet
