# frozen_string_literal: true

require 'dry-validation'

module Contracts
  # Basic URL regex.
  URL_REGEX = %r{^(?:http(s)?://)}
  # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#edmwebresource
  class EDMWebResource < Dry::Validation::Contract
    json do
      required(:wr_id).filled(:str?, format?: URL_REGEX)
      optional(:wr_format).array(:str?)
      # optional(:wr_is_referenced_by).maybe(:array).each(:str?, format?: URL_REGEX) # Fails on null values
      optional(:wr_has_service).value(:array).each do
        hash do
          required(:service_id).filled(:string)
          required(:service_conforms_to).array(:str?)
          optional(:service_implements).filled(:string)
        end
      end
    end
  end
end
