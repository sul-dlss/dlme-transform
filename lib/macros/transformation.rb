# frozen_string_literal: true

module Macros
  # Split helpers for traject mappings
  module Transformation
    # Append argument to end of each value in accumulator.
    def dlme_append(suffix)
      lambda do |_rec, acc|
        return if acc.compact.empty?

        acc.collect! { |v| v + suffix }
      end
    end

    # Adds a literal to accumulator if accumulator was empty
    #
    # @example
    #      to_field "title", extract_marc("245abc"), default("Unknown Title")
    def dlme_default(default_value)
      lambda do |_rec, acc|
        acc << default_value if acc.all?(&:blank?)
      end
    end

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
        acc.compact! # remove any nils
        return if acc.empty?

        acc.collect! do |v|
          # unicode whitespace class aware
          v.sub(/\A[[:space:]]+/, '').sub(/[[:space:]]+\Z/, '')
        end
      end
    end

    # Pass in a proc/lambda arg or a block (or both), that will be called on each
    # value already in the accumulator, to transform it. (Ie, with `#map!`/`#collect!` on your proc(s)).
    #
    # Due to how ruby syntax precedence works, the block form is probably not too useful
    # in traject config files, except with the `&:` trick.
    #
    # The "stabby lambda" may be convenient for passing an explicit proc argument.
    #
    # You can pass both an explicit proc arg and a block, in which case the proc arg
    # will be applied first.
    #
    # @example
    #    to_field("something"), extract_marc("something"), transform(&:upcase)
    #
    # @example
    #    to_field("something"), extract_marc("something"), transform(->(val) { val.tr('^a-z', "\uFFFD") })
    def dlme_transform(a_proc = nil, &block) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
      raise ArgumentError, 'Needs a transform proc arg or block arg' unless a_proc || block

      transformer_callable = if a_proc && block
                               # need to make a combo wrapper.
                               ->(val) { yield a_proc.call(val) }
                             elsif a_proc
                               a_proc
                             else
                               block
                             end

      lambda do |_rec, acc|
        return if acc.compact.empty?

        acc.collect! do |value|
          transformer_callable.call(value)
        end
      end
    end
  end
end
