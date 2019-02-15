# frozen_string_literal: true

require 'traject'
require 'adjust_cardinality'
require 'dlme_json_schema'

# Write the traject output to newline delmitited json
# This writer also casts fields that should be singular (like `id`) from lists.
# Finally, it runs the DLME IR schema validator on each output to ensure the config
# is writing a compliant message.
class DlmeJsonResourceWriter < Traject::LineWriter
  def serialize(context)
    attributes = context.output_hash.dup
    adjusted = AdjustCardinality.call(attributes)
    errors = validate(adjusted)
    raise "Transform produced invalid data:\n\t#{adjusted}" unless errors.empty?

    JSON.generate(adjusted).unicode_normalize
  end

  private

  def validate(json)
    DlmeJsonSchema.call(json).errors
  end
end
