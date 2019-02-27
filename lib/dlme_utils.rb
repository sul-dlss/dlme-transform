# frozen_string_literal: true

require 'active_support/benchmarkable'
require 'faraday'

module DLME
  # Misc. utilities for working with DLME data
  module Utils
    extend ActiveSupport::Benchmarkable

    def self.client
      Faraday.new do |builder|
        # builder.use :http_cache, store: Rails.cache

        builder.adapter Faraday.default_adapter
      end
    end

    def self.fetch_json(uri)
      resp = benchmark("DLME::Utils.fetch_json(#{uri})", level: :debug) do
        client.get uri
      end
      resp_content_type = resp.headers['content-type']
      raise "Unexpected response type '#{resp_content_type}' for #{uri}" unless resp_content_type == 'application/json'

      ::JSON.parse(resp.body)
    end

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
