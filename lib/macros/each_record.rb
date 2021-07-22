# frozen_string_literal: true

module Macros
  # Macros for post-processing data
  module EachRecord
    # Converts one or more fields from arrays or strings into hashes with language codes
    # NOTE: do *not* include cho_type_facet in fields list
    # @example
    #   convert_to_language_hash => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def convert_to_language_hash(*fields) # rubocop:disable Metrics/PerceivedComplexity
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
          unless unique_values.length == values.length # rubocop:disable Style/IfUnlessModifier these lines are long for a one liner
            ::DLME::Utils.logger.warn(format(log_msg_template, { msg: "values=#{values}; values array contains duplicates" }))
          end

          unique_values.each do |value|
            case value
            when Hash
              sub_values = value[:values].reject(&:nil?).reject(&:empty?)
              result[value[:language]] += sub_values.uniq.tap do |unique_sub_values|
                unless unique_sub_values.length == sub_values.length # rubocop:disable Style/IfUnlessModifier 2 lines good, one line bad
                  ::DLME::Utils.logger.warn(format(log_msg_template, { msg: "sub_values=#{sub_values}; sub_values array contains duplicates" }))
                end
              end
            else
              result['none'] += Array(value)
              err_msg = format(log_msg_template, { msg: "value=#{value}; 'none' not allowed as IR language key, language must be specified" })
              ::DLME::Utils.logger.error(err_msg)
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
