# frozen_string_literal: true

require 'traject_plus'

module Macros
  # DLME helpers for traject mappings
  module FieldExtraction
    extend TrajectPlus::Macros::JSON

    def extract_json_from_context(path)
      lambda do |rec, acc|
        result = rec[path]
        acc.replace([result]) if result
      end
    end

    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    def extract_person_date_role(person_key, date_key, role_key)
      # Extract a person, date, and role, then format the output.
      lambda do |rec, acc|
        person = JsonPath.on(rec, person_key).flatten[0]
        date = JsonPath.on(rec, date_key).flatten[0]
        role = JsonPath.on(rec, role_key).flatten[0]

        if role && !role.empty? && date && !date.empty? && person && !person.empty?
          acc << "#{role.capitalize}: #{person} #{date.delete(',')}"
        elsif role && !role.empty? && person && !person.empty?
          acc << "#{role.capitalize}: #{person}"
        elsif date && !date.empty? && person && !person.empty?
          acc << "#{person} #{date.delete(',')}"
        elsif person && !person.empty?
          acc << person
        end
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength

    def extract_with_fallback(record_fields = [])
      lambda do |record, accumulator|
        record_fields.each do |field_spec|
          extracted_values = extract_values_for_spec(record, field_spec)

          # 3. If we found something, populate and STOP
          if extracted_values.any?(&:present?)
            extracted_values.each { |v| accumulator << v if v.present? }
            break
          end
        end
      end
    end

    private

    # 1. Determine if it's a fixed-field slice or a standard field
    # Syntax: ['F041'] or ['F008', 35, 3]
    def extract_values_for_spec(record, field_spec)
      field_name = field_spec.is_a?(Array) ? field_spec[0] : field_spec
      raw_val = record[field_name]

      return [] if raw_val.nil? || raw_val.empty?

      if field_spec.is_a?(Array) && field_spec.length == 3
        # Handle fixed-field slice: [field, start, length]
        extract_fixed_field_value(raw_val, field_spec[1], field_spec[2])
      else
        # Handle standard field (can be string or array)
        Array(raw_val)
      end
    end

    # 2. Extract value from a fixed-field slice
    def extract_fixed_field_value(raw_val, start_pos, length)
      val = raw_val.is_a?(Array) ? raw_val.first : raw_val
      return [] unless val.is_a?(String) && val.length >= (start_pos + length)

      [val[start_pos, length].strip]
    end
  end
end
