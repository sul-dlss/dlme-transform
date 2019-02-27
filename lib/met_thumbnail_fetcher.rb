# frozen_string_literal: true

require 'dlme_utils'
require 'active_support/core_ext/object/blank'

# Grab a thumbnail URL from the Met web service
# API docs at https://metmuseum.github.io/
module MetThumbnailFetcher
  def self.fetch(ident)
    image_json = make_request(ident)

    return if image_json.blank?

    unless image_json['primaryImage']
      # Some records have null results
      DLME::Utils.logger.warn "No results found in #{ident}\n#{image_json}"
      return
    end

    image_json['primaryImage']
  end

  def self.make_request(id)
    DLME::Utils.fetch_json("https://collectionapi.metmuseum.org/public/collection/v1/objects/#{id}")
  end
  private_class_method :make_request
end
