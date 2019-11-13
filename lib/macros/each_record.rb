# frozen_string_literal: true

module Macros
  # Macros for post-processing data
  module EachRecord
    # NOTE: compute cho_type_facet BEFORE calling convert_to_language_hash fields
    # NOTE: do *not* include cho_type_facet in convert_to_language_hash fields
    # create cho_type_facet values from cho_edm_type and cho_has_type values,
    # add to context.output_hash if there's a value
    def add_cho_type_facet
      lambda do |_record, context|
        context.output_hash['cho_type_facet'] = {}
        context.output_hash['cho_edm_type']&.each do |el|
          if el.is_a?(Hash)
            lang_code = el[:language]
            val = cho_type_facet_val_from_hash(context, lang_code) if lang_code
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
    # @return [String or nil]
    def cho_type_facet_val_from_hash(context, lang_code)
      edm_type = lang_hash_value(context, 'cho_edm_type', lang_code)
      has_type_val = context.output_hash['cho_has_type']&.first
      has_type = lang_hash_value(context, 'cho_has_type', lang_code) if has_type_val.is_a?(Hash)
      hierarchical_val(edm_type, has_type)
    end

    # helper method for add_cho_type_facet
    # @return [String or nil]
    def cho_type_facet_val_from_array(context)
      edm_type = array_value(context, 'cho_edm_type')
      has_type_val = context.output_hash['cho_has_type']&.first
      has_type = array_value(context, 'cho_has_type') if has_type_val.is_a?(String)
      hierarchical_val(edm_type, has_type)
    end

    # helper method for add_cho_type_facet
    # @return [String or nil]
    def hierarchical_val(first, second)
      result = first if first.present?
      result = "#{result}:#{second}" if result && second.present?
      result
    end

    # helper method for add_cho_type_facet
    def array_value(context, field)
      raw_val = context.output_hash[field]
      raw_val&.first
    end

    # helper method for add_cho_type_facet
    def lang_hash_value(context, field, lang_code)
      lang_hash = context.output_hash[field]&.select { |el| el[:language] == lang_code }
      lang_hash.first[:values]&.first
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
