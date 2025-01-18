# frozen_string_literal: true

module Macros
  # DLME helpers for traject mappings
  module TitleExtraction
    # Extract a json title or truncated second field, if no title in record.
    def title_or(json_title, json_other)
      lambda do |rec, acc|
        title = rec[json_title]
        other = rec[json_other]
        title.present? ? acc.replace([title]) : acc.replace([truncate(other)])
      end
    end

    # Extract a json title and truncated second field or, if no title in record, extract truncated second field.
    def title_plus(json_title, json_other)
      lambda do |rec, acc|
        title = rec[json_title]
        other = rec[json_other]
        if other.present?
          title.present? ? acc.replace(["#{title} #{truncate(other)}"]) : acc.replace([truncate(other)])
        else
          acc.replace([title])
        end
      end
    end

    # Extract a json title and second field or, if no first title in record, extract
    # second field and put defualt string in first title spot.
    def title_plus_default(json_title, json_other, default)
      lambda do |rec, acc|
        title = rec[json_title]
        other = rec[json_other]

        value = [title.presence || default, other].compact.join(' ')
        acc << value unless value.empty?
      end
    end
  end
end
