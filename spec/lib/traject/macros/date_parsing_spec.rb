# frozen_string_literal: true

require 'macros/date_parsing'
require 'traject_plus'

RSpec.describe Macros::DateParsing do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
        extend Macros::DateParsing
      end
    end
  end

  describe 'single_year_from_string' do
    context 'Sun, 12 Nov 2017 14:08:12 +0000' do
      it 'gets 2017' do
        indexer.instance_eval do
          to_field 'int_array', accumulate { |record, *_| record[:value] }, single_year_from_string
        end

        expect(indexer.map_record(value: 'Sun, 12 Nov 2017 14:08:12 +0000')).to include 'int_array' => [2017]
      end
    end
  end

  describe 'range_array_from_positive_4digits_hyphen' do
    it 'parseable values' do
      indexer.instance_eval do
        to_field 'int_array', accumulate { |record, *_| record[:value] }, range_array_from_positive_4digits_hyphen
      end

      expect(indexer.map_record(value: '2019')).to include 'int_array' => [2019]
      expect(indexer.map_record(value: '2017-2019')).to include 'int_array' => [2017, 2018, 2019]
      expect(indexer.map_record(value: '2017 - 2019')).to include 'int_array' => [2017, 2018, 2019]
      expect(indexer.map_record(value: '2017- 2019')).to include 'int_array' => [2017, 2018, 2019]
    end
  end
end
