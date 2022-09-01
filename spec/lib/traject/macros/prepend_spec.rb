# frozen_string_literal: true

require 'macros/prepend'

RSpec.describe Macros::Prepend do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::Prepend
        extend TrajectPlus::Macros
      end
    end
  end

  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::Prepend
    end
  end
  let(:instance) { klass.new }
  let(:mock_context) { Traject::Indexer::Context.new }

  describe '#intelligent_prepend' do
    context 'with en language code' do
      let(:output) { [language: 'en', values: [+'value']] } # outputs nil

      it 'prepends the English prepend string' do
        callable = instance.intelligent_prepend('prepend string: ', 'السلسلة السابقة: ')
        expect(callable.call(nil, output)).to eq([['prepend string: value']])
      end
    end

    context 'with en language code and multiple values' do
      let(:output) { [language: 'en', values: [+'value_one', +'value_two']] } # outputs nil

      it 'prepends the English prepend string to all values' do
        callable = instance.intelligent_prepend('prepend string: ', 'السلسلة السابقة: ')
        expect(callable.call(nil, output)).to eq([['prepend string: value_one', 'prepend string: value_two']])
      end
    end

    context 'with other language code' do
      let(:output) { [language: 'ar-Arab', values: [+'القيمة']] } # outputs nested array

      it 'prepends the translated prepend string' do
        callable = instance.intelligent_prepend('prepend string: ', 'السلسلة السابقة: ')
        expect(callable.call(nil, output)).to eq([['السلسلة السابقة: القيمة']])
      end
    end

    context 'with no values in the accumulator' do
      let(:output) { [] } # outputs nested array

      it 'returns nil' do
        callable = instance.intelligent_prepend('prepend string: ', 'السلسلة السابقة: ')
        expect(callable.call(nil, output)).to eq(nil)
      end
    end
  end
end
