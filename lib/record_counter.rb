# frozen_string_literal: true

require 'concurrent'
require 'singleton'

module Dlme
  # A singleton counter for records.
  class RecordCounter
    include Singleton

    def initialize
      reset!
    end

    def increment
      @counter.increment
    end

    def count
      @counter.value
    end

    private

    def reset!
      @counter = Concurrent::AtomicFixnum.new(0)
    end
  end
end
