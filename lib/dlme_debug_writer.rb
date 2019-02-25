# frozen_string_literal: true

require 'traject'
require 'line_writer_fix_mixin'

# Temporary fix until https://github.com/traject/traject/pull/202 is merged.
class DlmeDebugWriter < Traject::DebugWriter
  include LineWriterFixMixin
end
