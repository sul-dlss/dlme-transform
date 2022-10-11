# frozen_string_literal: true

require 'adjust_cardinality'
require 'contracts'

# Write the traject output to newline delmitited json
# This writer also casts fields that should be singular (like `id`) from lists.
# Finally, it runs the DLME IR schema validator on each output to ensure the config
# is writing a compliant message.
class DlmeDebugWriter < Traject::LineWriter
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
    Contracts::CHO.new.call(json).errors
  end
end
