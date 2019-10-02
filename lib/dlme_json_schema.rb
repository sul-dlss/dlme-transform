# frozen_string_literal: true

require 'dry-schema'
# Responsible for describing the JSON schema for the intermediate representation.
# rubocop:disable Metrics/BlockLength

# See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#svcsservice
ServicesSchema = Dry::Schema.JSON do
  required(:service_id).filled(:string)
  required(:service_conforms_to).array(:str?)
  optional(:service_implements).filled(:string)
end

# See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#edmwebresource
EDMWebResourceSchema = Dry::Schema.JSON do
  required(:wr_id).filled(:string)
  optional(:wr_format).array(:str?)
  optional(:wr_has_service).value(:array).each do
    schema(ServicesSchema)
  end
end

DlmeJsonSchema = Dry::Schema.JSON do
  # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#edmprovidedcho
  optional(:cho_alternative).array(:str?)
  optional(:cho_contributor).array(:str?)
  optional(:cho_coverage).array(:str?)
  optional(:cho_creator).array(:str?)
  optional(:cho_date).array(:str?)
  optional(:cho_date_hijri).array(:str?)
  optional(:cho_date_range_norm).array(:integer) # this is an array of integers to capture the years in a range
  optional(:cho_dc_rights).array(:str?)
  optional(:cho_description).array(:str?)
  optional(:cho_edm_type).array(:str?, excluded_from?: ['NOT FOUND'])
  optional(:cho_extent).array(:str?)
  optional(:cho_format).array(:str?)
  optional(:cho_has_part).array(:str?)
  optional(:cho_has_type).array(:str?)
  optional(:cho_identifier).array(:str?)
  optional(:cho_is_part_of).array(:str?)
  optional(:cho_language).array(:str?, excluded_from?: ['NOT FOUND'])
  optional(:cho_medium).array(:str?)
  optional(:cho_provenance).array(:str?)
  optional(:cho_publisher).array(:str?)
  optional(:cho_relation).array(:str?)
  optional(:cho_same_as).array(:str?)
  optional(:cho_source).array(:str?)
  optional(:cho_spatial).array(:str?)
  optional(:cho_subject).array(:str?)
  optional(:cho_temporal).array(:str?)
  required(:cho_title).array(:str?)
  optional(:cho_type).array(:str?)

  # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#oreaggregation
  required(:id).filled(:string)
  optional('__source'.to_sym).filled(:string)
  # Since the IR is a flattened projection of the MAP, 'agg_aggregated_cho' is not used.
  required(:agg_data_provider).filled(:string)
  required(:agg_data_provider_country).filled(:string)
  optional(:agg_dc_rights).array(:str?)
  optional(:agg_edm_rights).array(:str?) # At least one is required

  optional(:agg_has_view).value(:array) do # 0 to n
    schema(EDMWebResourceSchema)
  end

  optional(:agg_is_shown_at).schema(EDMWebResourceSchema) # 0 or 1
  optional(:agg_is_shown_by).schema(EDMWebResourceSchema) # 0 or 1
  optional(:agg_preview).schema(EDMWebResourceSchema) # 0 or 1

  required(:agg_provider).filled(:string)
  required(:agg_provider_country).filled(:string)
  optional(:agg_same_as).array(:str?) # reference
end
# rubocop:enable Metrics/BlockLength
