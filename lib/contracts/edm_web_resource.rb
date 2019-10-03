# frozen_string_literal: true

module Contracts
  # See https://github.com/sul-dlss/dlme/blob/master/docs/application_profile.md#edmwebresource
  class EDMWebResource < Dry::Validation::Contract
    json do
      required(:wr_id).filled(:string)
      optional(:wr_format).array(:str?)
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
