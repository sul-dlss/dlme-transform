# frozen_string_literal: true

require 'uri'

module Macros
  # Macros for processing Eastview data.
  module Eastview
    # Generates a unique ID for an Eastview record based on a base ID and a URL.
    # The unique part is extracted from the 'd' parameter of the URL's query string.
    # Records are skipped if the URL is missing, empty, malformed, or
    # if the 'd' parameter is not found or is empty.
    #
    # @param from_base_id_field [Symbol] The field in the record containing the base ID.
    # @param from_url_field [Symbol] The field in the record containing the URL string.
    # @return [Proc] A Traject macro lambda.
    def generate_eastview_issue_id(from_base_id_field, from_url_field)
      lambda do |record, accumulator, context|
        base_id = record[from_base_id_field]
        url_string = record[from_url_field]

        unique_part = process_eastview_url_and_get_unique_part(url_string, base_id, from_url_field, context)
        next unless unique_part

        # If all checks pass, create the ID.
        add_eastview_id_to_accumulator(base_id, unique_part, accumulator)
      end
    end

    private

    # Processes the URL string through validation and unique part extraction.
    # Skips the record and returns nil if any validation or extraction fails.
    # @return [String, nil] The unique part if successful, nil otherwise.
    def process_eastview_url_and_get_unique_part(url_string, base_id, from_url_field, context)
      return nil unless url_string_valid?(url_string, base_id, from_url_field, context)

      extract_unique_part_from_url(url_string, base_id, from_url_field, context)
    end

    # Checks if the URL string is present and not empty.
    # If not, logs a debug message and skips the record.
    # @return [Boolean] true if valid, false otherwise.
    def url_string_valid?(url_string, base_id, from_url_field, context)
      if url_string.blank?
        warn "DEBUG: SKIPPING record '#{base_id}' because the '#{from_url_field}' field is missing or empty."
        context.skip!("No URL found in field '#{from_url_field}' to generate ID")
        false
      else
        true
      end
    end

    # Extracts the unique part (from 'd' parameter) from a URL string.
    # Handles URI parsing errors and missing/empty 'd' parameters.
    # @return [String, nil] The unique part if found, nil otherwise.
    def extract_unique_part_from_url(url_string, base_id, from_url_field, context)
      params = parse_url_query_params(url_string, base_id, from_url_field, context)
      return nil unless params # If parsing failed, params will be nil and context.skip! already called

      validate_and_get_d_param(params, url_string, base_id, from_url_field, context)
    end

    # Parses the URL string and returns query parameters as a hash.
    # Logs a debug message and skips the record if the URL is malformed.
    # @return [Hash, nil] Query parameters hash if successful, nil otherwise.
    def parse_url_query_params(url_string, base_id, from_url_field, context)
      uri = URI.parse(url_string)
      URI.decode_www_form(String(uri.query)).to_h
    rescue URI::InvalidURIError
      warn "DEBUG: SKIPPING record '#{base_id}' because it has a malformed URL in '#{from_url_field}': #{url_string}"
      context.skip!("Malformed URL in field '#{from_url_field}': #{url_string}")
      nil
    end

    # Validates the 'd' parameter from the parsed query parameters.
    # Logs a debug message and skips the record if the 'd' parameter is missing or empty.
    # @return [String, nil] The 'd' parameter value if valid, nil otherwise.
    def validate_and_get_d_param(params, url_string, base_id, from_url_field, context)
      unique_part = params['d']
      if unique_part.blank?
        warn "DEBUG: SKIPPING record '#{base_id}' because its URL does not contain a 'd' parameter: #{url_string}"
        context.skip!("URL in '#{from_url_field}' does not contain 'd' parameter")
        nil
      else
        unique_part
      end
    end

    # Get issue date for the issue-text field.
    # @return [String, nil] The issue date if found, nil otherwise.
    def eastview_issue_date
      lambda do |record, accumulator|
        issue_texts = record['issue-text']
        return if issue_texts.nil?

        dates = Array(issue_texts).flat_map do |text|
          text.scan(/(\d{4}[-.]\d{2}[-.]\d{2})/).flatten.map { |d| d.tr('.', '-') }
        end.compact

        accumulator.concat(dates) unless dates.empty?
      end
    end

    # Adds the generated Eastview ID to the accumulator.
    # @param base_id [String] The base ID of the record.
    # @param unique_part [String] The unique part extracted from the URL.
    # @param accumulator [Array] The Traject accumulator.
    def add_eastview_id_to_accumulator(base_id, unique_part, accumulator)
      safe_issue_part = unique_part.gsub(/[^a-zA-Z0-9-]/, '_')
      unique_id = "#{base_id}_#{safe_issue_part}"
      accumulator << unique_id
    end
  end
end
