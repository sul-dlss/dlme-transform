# frozen_string_literal: true

module Macros
  # Macros for extracting language and derecting script from title
  module Brooklyn
    def brooklyn_collection_id
      lambda do |record, accumulator|
        return if record['collections'][0]['folder'].nil?

        value = record['collections'][0]['folder']
        value = "brooklyn-museum-#{value}".tr('_', '-') if value.present?
        accumulator << value if value && value != false
      end
    end

    def brooklyn_rights
      lambda do |record, accumulator|
        return if record['rights_type']['public_name'].nil?

        value = record['rights_type']['public_name']
        accumulator << value if value && value != false
      end
    end
  end
end
