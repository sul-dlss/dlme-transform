# frozen_string_literal: true

require 'dlme_utils'

module Macros
  # Macros for post-processing data
  module EachRecord
    class UnspecifiedLanguageError < RuntimeError; end

    # Converts one or more fields from arrays or strings into hashes with language codes
    # NOTE: do *not* include cho_type_facet in fields list
    # @example
    #   convert_to_language_hash => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def convert_to_language_hash(*fields)
      # If needed for the log messages, getting caller info here is more helpful, because it'll
      # get us the calling config (invoking caller_locations from the lambda returns a call stack
      # entirely within the traject gem, besides this method).
      # caller_locations[0] is the current stack frame, and caller_locations[1] is its direct caller.
      config_file_path = caller_locations(1, 1).first.path

      lambda do |_record, context|
        context.output_hash.select { |key, _values| fields.include?(key) }.each do |key, values|
          result = Hash.new { [] }
          log_msg_template = "#{config_file_path}: key=#{key}; %<msg>s.  Check source data and/or traject config for errors."

          unique_values = values.uniq

          unique_values.each do |value|
            case value
            when Hash
              sub_values = value[:values].compact.reject(&:empty?)
              html_cleaned = html_check(sub_values)
              sub_values = html_cleaned
              result[value[:language]] ||= [] # Initialize with empty array if not present
              result[value[:language]] += sub_values.uniq
            else
              err_msg = format(log_msg_template, { msg: "value=#{value}; 'none' not allowed as IR language key, language must be specified" })
              ::DLME::Utils.logger.error(err_msg)
              raise UnspecifiedLanguageError, err_msg
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

    # helper method for HTML tag checks in values
    def html_check(values)
      cleaned_values = []
      values.each do |value|
        html_fragment = Nokogiri::HTML.fragment(value)
        value = html_fragment.text unless html_fragment.elements.empty?
        cleaned_values.push(value)
      end
      cleaned_values
    end

    # helper method to flatten an array of arrays
    def flatten_array
      lambda do |_record, accumulator, _context|
        accumulator.flatten!
      end
    end
  end
end
