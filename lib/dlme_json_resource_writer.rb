# frozen_string_literal: true

require 'traject'
require 'adjust_cardinality'
require 'dlme_json_schema'

# Write the traject output to newline delmitited json
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
