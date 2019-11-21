# frozen_string_literal: true

module Contracts
  # rubocop:disable Metrics/BlockLength
  # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#edmprovidedcho
  class CHO < Dry::Validation::Contract
    json do
      optional(:cho_alternative).value(:hash?)
      optional(:cho_contributor).value(:hash?)
      optional(:cho_coverage).value(:hash?)
      optional(:cho_creator).value(:hash?)
      optional(:cho_date).value(:hash?)
      optional(:cho_date_range_hijri).array(:integer)
      optional(:cho_date_range_norm).array(:integer)
      optional(:cho_dc_rights).value(:hash?)
      optional(:cho_description).value(:hash?)
      optional(:cho_edm_type) { hash? { each(:str?, excluded_from?: ['NOT FOUND']) } }
      optional(:cho_extent).value(:hash?)
      optional(:cho_format).value(:hash?)
      optional(:cho_has_part).value(:hash?)
      optional(:cho_has_type).value(:hash?)
      optional(:cho_identifier).array(:str?)
      optional(:cho_is_part_of).value(:hash?)
      optional(:cho_language) { hash? { each(:str?, excluded_from?: ['NOT FOUND']) } }
      optional(:cho_medium).value(:hash?)
      optional(:cho_provenance).value(:hash?)
      optional(:cho_publisher).value(:hash?)
      optional(:cho_relation).value(:hash?)
      optional(:cho_same_as).array(:str?)
      optional(:cho_source).value(:hash?)
      optional(:cho_spatial).value(:hash?)
      optional(:cho_subject).value(:hash?)
      optional(:cho_temporal).value(:hash?)
      required(:cho_title).value(:hash?)
      optional(:cho_type).value(:hash?)
      optional(:cho_type_facet).value(:hash?)

      # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#oreaggregation
      # required(:transform_version).filled(:string)
      # required(:transform_timestamp).filled(:string)
      required(:id).filled(:string)
      optional('__source'.to_sym).filled(:string)
      # Since the IR is a flattened projection of the MAP, 'agg_aggregated_cho' is not used.
      required(:agg_data_provider).value(:hash?)
      required(:agg_data_provider_country).value(:hash?)
      optional(:agg_dc_rights).array(:str?)
      optional(:agg_edm_rights).array(:str?) # At least one is required

      optional(:agg_has_view).value(:array) # 0 to n
      optional(:agg_is_shown_at) # 0 or 1
      optional(:agg_is_shown_by) # 0 or 1
      optional(:agg_preview) # 0 or 1

      required(:agg_provider).value(:hash?)
      required(:agg_provider_country).value(:hash?)
      optional(:agg_same_as).array(:str?) # reference
    end

    # Because we use these rules for multiple fields, express the validation
    # logic as a Proc so we have a single implementation of each rule with many
    # uses, rather than repeating this code as a block passed to each
    # field-specific rule below
    #
    # Note that these class method *must* be defined *above* the `rule()` calls
    # below
    def self.web_resource_validation_rule
      proc do
        error_message = key? ? validate_web_resource(value) : ''
        key.failure(error_message) unless error_message.empty?
      end
    end

    # rubocop:disable Metrics/AbcSize
    def self.required_language_specific_rule
      proc do
        key.failure('no values provided') if value.keys.empty? || value.values&.first&.empty?
        unexpected_keys = value.keys - expected_language_values
        key.failure("unexpected language code(s) found in #{key.path.keys.first}: #{unexpected_keys.join(', ')}") if
          unexpected_keys.any?
        unexpected_values = value.values&.first&.reject { |value| value.is_a?(String) }
        key.failure("unexpected non-string value(s) found in #{key.path.keys.first}: #{unexpected_values}") if
          unexpected_values&.any?
      end
    end
    # rubocop:enable Metrics/AbcSize

    def self.optional_language_specific_rule
      proc do
        # Short-circuit if value is empty: `next` in a Proc functions like a return
        next unless value.respond_to?(:keys)

        unexpected_keys = value.keys - expected_language_values
        key.failure("unexpected language code(s) found in #{key.path.keys.first}: #{unexpected_keys.join(', ')}") if
          unexpected_keys.any?
        unexpected_values = value.values&.first&.reject { |value| value.is_a?(String) }
        key.failure("unexpected non-string value(s) found in #{key.path.keys.first}: #{unexpected_values}") if
          unexpected_values&.any?
      end
    end

    rule(:cho_description, &optional_language_specific_rule)

    rule(:cho_title, &required_language_specific_rule)
    rule(:agg_data_provider, &required_language_specific_rule)
    rule(:agg_data_provider_country, &required_language_specific_rule)
    rule(:agg_provider, &required_language_specific_rule)
    rule(:agg_provider_country, &required_language_specific_rule)

    rule(:agg_is_shown_at, &web_resource_validation_rule)
    rule(:agg_is_shown_by, &web_resource_validation_rule)
    rule(:agg_preview, &web_resource_validation_rule)
    rule(:agg_has_view).each(&web_resource_validation_rule)

    private

    def expected_language_values
      Settings.acceptable_bcp47_codes.push('none')
    end

    def validate_web_resource(resource)
      errors = Contracts::EDMWebResource.new.call(resource).errors
      return '' if errors.empty?

      errors.messages.map(&:text).join(', ')
    end
  end
  # rubocop:enable Metrics/BlockLength
end
