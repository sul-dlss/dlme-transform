# frozen_string_literal: true

module Macros
  # Macros for post-processing data
  module EachRecord
    # Converts one or more fields from arrays or strings into hashes with language codes
    # NOTE: do *not* include cho_type_facet in fields list
    # @example
    #   convert_to_language_hash => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def convert_to_language_hash(*fields)
      lambda do |_record, context|
        context.output_hash.select { |key, _values| fields.include?(key) }.each do |key, values|
          result = Hash.new { [] }

          values.each do |value|
            case value
            when Hash
              result[value[:language]] += value[:values]
            else
              result['none'] += Array(value)
            end
          end

          context.output_hash[key] = result
        end
      end
    end

    # NOTE: call add_cho_type_facet AFTER calling convert_to_language_hash fields
    #   (do *not* include cho_type_facet in convert_to_language_hash fields)
    # Adds cho_type_facet field to context.output_hash (but only if there's a value).
    #   Create cho_type_facet hierarchical values for each language present (including 'none')
    # NOTE: we anticipate only one value for each language.
    def add_cho_type_facet
      lambda do |_record, context|
        context.output_hash['cho_type_facet'] = {}
        cho_has_type_raw_hash = context.output_hash['cho_has_type']
        context.output_hash['cho_edm_type']&.each_pair do |lang, values|
          edm_type_first = values&.first
          has_type_first = cho_has_type_raw_hash[lang]&.first if cho_has_type_raw_hash
          val = hierarchical_val(edm_type_first, has_type_first)
          context.output_hash['cho_type_facet'][lang] = val if val.present?
        end
        context.output_hash.delete('cho_type_facet') if context.output_hash['cho_type_facet'].empty?
      end
    end

    HIER_LEVEL_SEP_CHAR = ':'

    # helper method for add_cho_type_facet
    # @return [String or nil]
    def hierarchical_val(*values)
      non_nil_values = values.compact
      return non_nil_values if non_nil_values.count < 2

      [non_nil_values.first, non_nil_values.join(HIER_LEVEL_SEP_CHAR)]
    end
  end
end
