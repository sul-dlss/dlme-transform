# frozen_string_literal: true

require 'macros/date_parsing'
require 'macros/lausanne'

RSpec.describe Macros::Lausanne do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::DateParsing
        extend Macros::Lausanne
        extend TrajectPlus::Macros
      end
    end
  end

  let(:raw_val_lambda) do
    lambda do |record, accumulafromr|
      accumulafromr << record[:raw]
    end
  end

  describe '#lausanne_date_range' do
    before do
      indexer.instance_eval do
        to_field 'range', lausanne_date_range
      end
    end

    context 'when from and to populated' do
      it 'both dates and range are valid' do
        expect(indexer.map_record('from' => '-2', 'to' => '1')).to include 'range' => [-2, -1, 0, 1]
        expect(indexer.map_record('from' => '-11', 'to' => '1')).to include 'range' => (-11..1).to_a
        expect(indexer.map_record('from' => '-100', 'to' => '-99')).to include 'range' => [-100, -99]
        expect(indexer.map_record('from' => '-1540', 'to' => '-1538')).to include 'range' => (-1540..-1538).to_a
        expect(indexer.map_record('from' => '0', 'to' => '99')).to include 'range' => (0..99).to_a
        expect(indexer.map_record('from' => '1', 'to' => '10')).to include 'range' => (1..10).to_a
        expect(indexer.map_record('from' => '300', 'to' => '319')).to include 'range' => (300..319).to_a
        expect(indexer.map_record('from' => '666', 'to' => '666')).to include 'range' => [666]
      end
    end

    it 'when one date is empty, range is a single year' do
      expect(indexer.map_record('from' => '300')).to include 'range' => [300]
      expect(indexer.map_record('to' => '666')).to include 'range' => [666]
    end

    it 'when both dates are empty, no error is raised' do
      expect(indexer.map_record({})).to eq({})
    end

    it 'date strings with no numbers are interpreted as missing' do
      expect(indexer.map_record('from' => 'not_a_number', 'to' => 'me_too')).to eq({})
    end
  end

  describe '#lausanne_date_string' do
    before do
      indexer.instance_eval do
        to_field 'range', lausanne_date_string
      end
    end

    context 'when from and to populated' do
      it 'both dates and range are valid' do
        expect(indexer.map_record('from' => '-2', 'to' => '1')).to include 'range' => ['-2 to 1']
        expect(indexer.map_record('from' => '-11', 'to' => '1')).to include 'range' => ['-11 to 1']
        expect(indexer.map_record('from' => '-100', 'to' => '-99')).to include 'range' => ['-100 to -99']
        expect(indexer.map_record('from' => '-1540', 'to' => '-1538')).to include 'range' => ['-1540 to -1538']
        expect(indexer.map_record('from' => '0', 'to' => '99')).to include 'range' => ['0 to 99']
        expect(indexer.map_record('from' => '1', 'to' => '10')).to include 'range' => ['1 to 10']
        expect(indexer.map_record('from' => '300', 'to' => '319')).to include 'range' => ['300 to 319']
        expect(indexer.map_record('from' => '666', 'to' => '666')).to include 'range' => ['666 to 666']
      end
    end

    it 'when one date is empty, range is a single year' do
      expect(indexer.map_record('from' => '300')).not_to include 'range' => ['300']
      expect(indexer.map_record('to' => '666')).not_to include 'range' => ['666']
    end

    it 'when both dates are empty, no error is raised' do
      expect(indexer.map_record({})).to eq({})
    end

    it 'date strings with no numbers are interpreted as missing' do
      expect(indexer.map_record('from' => 'not_a_number', 'to' => 'me_too')).to eq({})
    end
  end
end
