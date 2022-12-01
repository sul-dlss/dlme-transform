# frozen_string_literal: true

require 'csv'
require 'macros/csv'

RSpec.describe Macros::Csv do
  let(:klass) do
    Class.new do
      include Macros::Csv
    end
  end

  let(:instance) { klass.new }

  describe '#parse_csv' do
    it 'returns a Proc' do
      expect(instance.parse_csv).to be_a(Proc)
    end

    context 'with no values in accumulator' do
      it 'returns the empty accumulator' do
        accumulator_original = []
        callable = instance.parse_csv
        expect(callable.call(nil, accumulator_original)).to eq([])
      end
    end

    context 'with a string value in accumulator' do
      it 'returns the original accumulator' do
        accumulator_original = ['this is my dummy string']
        callable = instance.parse_csv
        expect(callable.call(nil, accumulator_original)).to eq(['this is my dummy string'])
      end
    end

    context 'with an array value in accumulator' do
      it 'returns an array with each element in the accumulator' do
        accumulator_original = ["['this', 'is', 'my', 'dummy', 'string']"]
        callable = instance.parse_csv
        expect(callable.call(nil, accumulator_original)).to eq(['this', 'is', 'my', 'dummy', 'string'])
      end
    end

    context 'with weird comma problem' do
      it 'parses ok' do
        text = %q("'test,'")
        result = CSV.parse(text, liberal_parsing: true, quote_char: "'")
        expect(result.length).to eq(1)
      end
    end
  end
end
