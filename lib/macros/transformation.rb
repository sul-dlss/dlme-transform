# frozen_string_literal: true

module Macros
  # Split helpers for traject mappings
  module Transformation
    # Run ruby `gsub` on each value in accumulator, with pattern and replace value given.
    def dlme_gsub(pattern, replace)
      lambda do |_rec, acc|
        return if acc.compact.empty?

        acc.collect! { |v| v.gsub(pattern, replace) }
      end
    end

    # Run ruby `split` on each value in the accumulator, with separator
    # given, flatten all results into single array as accumulator.
    # Will generally result in more individual values in accumulator as output than were
    # there in input, as input values are split up into multiple values.
    def dlme_split(separator)
      lambda do |_rec, acc|
        return if acc.compact.empty?

        acc.replace(acc.flat_map { |v| v.split(separator) })
      end
    end

    # For each value in accumulator, remove all leading or trailing whitespace
    # (unique aware). Like ruby #strip, but whitespace-aware
    #
    # @example
    #     to_field "title", extract_marc("245"), strip
    def dlme_strip
      lambda do |_rec, acc|
        return if acc.compact.empty?

        acc.collect! do |v|
          # unicode whitespace class aware
          v.sub(/\A[[:space:]]+/, '').sub(/[[:space:]]+\Z/, '')
        end
      end
    end
  end
end
