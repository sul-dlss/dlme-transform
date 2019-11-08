# frozen_string_literal: true

require 'concurrent'
require 'singleton'

module Dlme
  # A singleton exception collector
  class ExceptionCollector
    include Singleton

    def initialize
      @exception_collector = Concurrent::Array.new
    end

    delegate :<<, :count, :each, to: :exception_collector

    private

    attr_reader :exception_collector
  end
end
