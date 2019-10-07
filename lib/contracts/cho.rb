# frozen_string_literal: true

module Contracts
  # rubocop:disable Metrics/BlockLength
  # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#edmprovidedcho
  class CHO < Dry::Validation::Contract
    json do
      optional(:cho_alternative).array(:str?)
      optional(:cho_contributor).array(:str?)
      optional(:cho_coverage).array(:str?)
      optional(:cho_creator).array(:str?)
      optional(:cho_date).array(:str?)
      optional(:cho_date_hijri).array(:str?)
      optional(:cho_date_range_norm).array(:integer) # this is an array of integers to capture the years in a range
      optional(:cho_dc_rights).array(:str?)
      optional(:cho_description).array(:str?)
      optional(:cho_edm_type) { array? { each(:str?, excluded_from?: ['NOT FOUND']) } }
      optional(:cho_extent).array(:str?)
      optional(:cho_format).array(:str?)
      optional(:cho_has_part).array(:str?)
      optional(:cho_has_type).array(:str?)
      optional(:cho_identifier).array(:str?)
      optional(:cho_is_part_of).array(:str?)
      optional(:cho_language) { array? { each(:str?, excluded_from?: ['NOT FOUND']) } }
      optional(:cho_medium).array(:str?)
      optional(:cho_provenance).array(:str?)
      optional(:cho_publisher).array(:str?)
      optional(:cho_relation).array(:str?)
      optional(:cho_same_as).array(:str?)
      optional(:cho_source).array(:str?)
      optional(:cho_spatial).array(:str?)
      optional(:cho_subject).array(:str?)
      optional(:cho_temporal).array(:str?)
      required(:cho_title).value(:hash?)
      optional(:cho_type).array(:str?)

      # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#oreaggregation
      required(:id).filled(:string)
      optional('__source'.to_sym).filled(:string)
      # Since the IR is a flattened projection of the MAP, 'agg_aggregated_cho' is not used.
      required(:agg_data_provider).filled(:string)
      required(:agg_data_provider_country).filled(:string)
      optional(:agg_dc_rights).array(:str?)
      optional(:agg_edm_rights).array(:str?) # At least one is required

      optional(:agg_has_view).value(:array) # 0 to n
      optional(:agg_is_shown_at) # 0 or 1
      optional(:agg_is_shown_by) # 0 or 1
      optional(:agg_preview) # 0 or 1

      required(:agg_provider).filled(:string)
      required(:agg_provider_country).filled(:string)
      optional(:agg_same_as).array(:str?) # reference
    end

    rule(:cho_title) do
      key.failure('no values provided') if value.keys.empty?
      unexpected_keys = value.keys - Macros::DLME.acceptable_bcp47_codes.push('none')
      key.failure("unexpected language code(s) found in #{key.path.keys.first}: #{unexpected_keys.join(', ')}") if
        unexpected_keys.any?
    end

    rule(:agg_is_shown_at) do
      error_message = key? ? validate_web_resource(value) : ''
      key.failure(error_message) unless error_message.empty?
    end

    rule(:agg_is_shown_by) do
      error_message = key? ? validate_web_resource(value) : ''
      key.failure(error_message) unless error_message.empty?
    end

    rule(:agg_preview) do
      error_message = key? ? validate_web_resource(value) : ''
      key.failure(error_message) unless error_message.empty?
    end

    rule(:agg_has_view) do
      Array(value).each do |resource|
        error_message = key? ? validate_web_resource(resource) : ''
        key.failure(error_message) unless error_message.empty?
      end
    end

    def validate_web_resource(resource)
      errors = Contracts::EDMWebResource.new.call(resource).errors
      return '' if errors.empty?

      errors.messages.map(&:text).join(', ')
    end
  end
  # rubocop:enable Metrics/BlockLength
end
