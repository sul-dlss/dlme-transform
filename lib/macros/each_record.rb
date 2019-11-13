# frozen_string_literal: true

module Macros
  # Macros for post-processing data
  module EachRecord
    # NOTE: compute cho_type_facet BEFORE calling convert_to_language_hash fields, and
    #   do *not* include cho_type_facet in convert_to_language_hash fields
    # Create cho_type_facet hierarchical values from cho_edm_type and cho_has_type values
    #   for each language present (or 'none')
    # Add cho_type_facet field to context.output_hash only if there's a value
    # NOTE: we expect only one value for each language (including 'none').
    # NOTE: if `cho_edm_type` values are Hashes (lang specified), `cho_has_type` values must also be Hashes to be included
    #   Similarly, if `cho_edm_type` values are Strings (no lang), `cho_has_type` values must also be Strings to be included
    def add_cho_type_facet
      lambda do |_record, context|
        context.output_hash['cho_type_facet'] = {}
        context.output_hash['cho_edm_type']&.each do |el|
          if el.is_a?(Hash)
            lang_code = el[:language]
            val = cho_type_facet_val_from_hash(context, lang_code)
            context.output_hash['cho_type_facet'][lang_code] = [val] if val.present?
          else
            val = cho_type_facet_val_from_array(context)
            context.output_hash['cho_type_facet']['none'] = [val] if val.present?
          end
        end
        context.output_hash.delete('cho_type_facet') if context.output_hash['cho_type_facet'].empty?
      end
    end

    # helper method for add_cho_type_facet
    # NOTE: `cho_has_type` values must (also) be Hashes to be included
    # @return [String or nil] value for hierarchical facet when `cho_edm_type` values are Hashes (lang specified)
    def cho_type_facet_val_from_hash(context, lang_code)
      edm_type = lang_hash_first_value(context, 'cho_edm_type', lang_code)
      has_type = lang_hash_first_value(context, 'cho_has_type', lang_code)
      hierarchical_val(edm_type, has_type)
    end

    # helper method for add_cho_type_facet
    # NOTE: `cho_has_type` values must (also) be Strings to be included
    # @return [String or nil] value for hierarchical facet when `cho_edm_type` values are Strings (no lang specified)
    def cho_type_facet_val_from_array(context)
      edm_type = array_first_value(context, 'cho_edm_type')
      has_type = array_first_value(context, 'cho_has_type')
      hierarchical_val(edm_type, has_type)
    end

    # helper method for add_cho_type_facet
    # @return [String or nil]
    def hierarchical_val(root, child)
      result = root if root.present?
      result = "#{result}:#{child}" if result && child.present?
      result
    end

    # helper method for add_cho_type_facet
    def array_first_value(context, field)
      raw_val = context.output_hash[field]
      raw_val.first if raw_val&.first.is_a?(String)
    end

    # helper method for add_cho_type_facet
    def lang_hash_first_value(context, field, lang_code)
      raw_hash_for_lang = context.output_hash[field]&.select { |el| el.is_a?(Hash) && el[:language] == lang_code }
      raw_hash_for_lang.first[:values]&.first if raw_hash_for_lang&.first.is_a?(Hash)
    end

    # Converts one or more fields from arrays or strings into hashes with language codes
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
  end
end
