# frozen_string_literal: true

require 'traject'
require 'adjust_cardinality'
require 'dlme_json_schema'
require 'line_writer_fix_mixin'

# Write the traject output to newline delmitited json
# This writer also casts fields that should be singular (like `id`) from lists.
# Finally, it runs the DLME IR schema validator on each output to ensure the config
# is writing a compliant message.
class DlmeJsonResourceWriter < Traject::LineWriter
  # Temporary fix until https://github.com/traject/traject/pull/202 is merged.
  include LineWriterFixMixin

  def serialize(context)
    attributes = context.output_hash.dup
    adjusted = AdjustCardinality.call(attributes)
    errors = validate(adjusted)
    return JSON.generate(adjusted).unicode_normalize if errors.empty?

    raise "Transform produced invalid data.\n\n" \
      "The errors are: #{errors.messages}}\n\n" \
      "The data looked like this:\n" \
      "#{JSON.pretty_generate(adjusted)}"
  end

  private

  def validate(json)
    DlmeJsonSchema.call(json).errors
  end
end
