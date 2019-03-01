# frozen_string_literal: true

require 'record_counter'

each_record do |_|
  Dlme::RecordCounter.instance.increment
end
