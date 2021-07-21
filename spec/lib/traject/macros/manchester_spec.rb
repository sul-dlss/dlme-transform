# frozen_string_literal: true

require 'macros/date_parsing'
require 'macros/manchester'

RSpec.describe Macros::Manchester do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
        extend Macros::DateParsing
        extend Macros::Manchester
      end
    end
  end

  describe '#manchester_solar_hijri_range' do
    before do
      indexer.instance_eval do
        to_field 'solar_hijri_range', accumulate { |record, *_| record[:value] }, manchester_solar_hijri_range
      end
    end

    it 'missing value' do
      expect(indexer.map_record({})).to eq({})
    end
  end
end
