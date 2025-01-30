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
  end
end
