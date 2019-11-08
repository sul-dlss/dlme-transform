# frozen_string_literal: true

require 'exception_collector'

after_processing do
  warn "Encountered #{Dlme::ExceptionCollector.instance.count} date parsing errors:" if
    Dlme::ExceptionCollector.instance.count.positive?

  Dlme::ExceptionCollector.instance.each do |exception|
    warn exception
  end
end
