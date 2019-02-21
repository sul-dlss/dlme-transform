require 'concurrent'

module Dlme
  # A singleton counter for records.
  class RecordCounter
    include Singleton

    def initialize
      @counter = Concurrent::AtomicFixnum.new(0)
    end

    def increment
      @counter.increment
    end

    def count
      @counter.value
    end
  end
end
