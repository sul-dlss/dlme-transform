# frozen_string_literal: true

require 'dlme_utils'

module Macros
  # Macros for extracting Stanford Specific MODS values from Nokogiri documents
  module IIIF
    # Download a IIIF manifest and return its data
    # @param [String] manifest the url to a IIIF manifest
    # @return [Hash] the data from the remote IIIF manifest
    def grab_iiif_manifest(manifest)
      ::DLME::Utils.fetch_json(manifest)
    rescue StandardError => e
      msg = "Error retrieving IIIF Manifest: #{e}"
      ::DLME::Utils.logger.error msg
      []
    end

    # Retrieve the thumbnail from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the thumbnail id
    def iiif_thumbnail_id(iiif_json)
      service = iiif_json.dig('thumbnail')
      service = service.first if service.is_a?(Array)
      service.dig('@id')
    end

    # Retrieve the thumbnail service id from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the thumbnail service id
    def iiif_thumbnail_service_id(iiif_json)
      service = iiif_json.dig('thumbnail', 'service')
      service = service.first if service.is_a?(Array)
      service.dig('@id')
    end

    # Retrieve the thumbnail service protocol from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the thumbnail service protocol
    def iiif_thumbnail_service_protocol(iiif_json)
      service = iiif_json.dig('thumbnail', 'service')
      service = service.first if service.is_a?(Array)
      iiif_service_conforms_to(service.dig('profile'))
    end

    # Retrieve the thumbnail service API spec url from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the url for the service API specification
    def iiif_thumbnail_service_conforms_to(iiif_json)
      service = iiif_json.dig('thumbnail', 'service')
      service = service.first if service.is_a?(Array)
      iiif_service_conforms_to(service.dig('profile'))
    end

    # Retrieve the sequence id from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the sequence id
    def iiif_sequence_id(iiif_json)
      rep_iiif_resource(iiif_json).dig('service', '@id')
    end

    # Retrieve the service sequence id from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the service sequence id
    def iiif_sequence_service_id(iiif_json)
      rep_iiif_resource(iiif_json).dig('service', '@id')
    end

    # Retrieve the service protocol from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the service protocol
    def iiif_sequence_service_protocol(iiif_json)
      rep_iiif_resource(iiif_json).dig('service', 'profile')
    end

    # Retrieve the service specification for the first image resource from the IIIF manifest document
    # @param [Hash] iiif_json the IIIF document
    # @return [String] the url for the service API specification
    def iiif_sequence_service_conforms_to(iiif_json)
      # iiif_service_conforms_to(rep_iiif_resource(iiif_json).dig('service', 'profile'))
      rep_iiif_resource(iiif_json).dig('service', 'profile')
    end

    private

    def rep_iiif_resource(manifest_json)
      manifest_json['sequences'].first['canvases'].first['images'].first['resource'] || {}
    end

    def iiif_service_conforms_to(service_profile)
      # Using the thumbnail service profile for now
      return service_profile if %w[
        http://iiif.io/api/image/
        http://iiif.io/api/auth/
        http://iiif.io/api/presentation/
        http://iiif.io/api/search/
        http://iiif.io/api/image/2/level2.json
        http://iiif.io/api/image/2/level1.json
        http://iiif.io/api/image/1/level2.json
      ].include? service_profile
    end
  end
end
