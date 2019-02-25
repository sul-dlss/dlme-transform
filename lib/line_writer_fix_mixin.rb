# frozen_string_literal: true

require 'traject'

# Temporary fix until https://github.com/traject/traject/pull/202 is merged.
module LineWriterFixMixin
  def close
    return if @output_file == $stdout

    super
  end
end
