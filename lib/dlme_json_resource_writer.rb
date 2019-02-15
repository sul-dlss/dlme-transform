# frozen_string_literal: true

require 'traject'

require_relative 'adjust_cardinality'

# Write the traject output to newline delmitited json
class DlmeJsonResourceWriter < Traject::LineWriter
  def serialize(context)
    attributes = context.output_hash.dup
    JSON.generate(AdjustCardinality.call(attributes)).unicode_normalize
  end
end
