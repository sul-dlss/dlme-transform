# frozen_string_literal: true

require 'macros/transformation'

RSpec.describe Macros::Transformation do
  let(:klass) do
    Class.new do
      include Macros::Transformation
      include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe '#dlme_default' do
    context 'when accumulator has a value' do
      let(:output) { ['value'] }

      it 'does nothing' do
        callable = instance.dlme_default('default')
        expect(callable.call(nil, output)).to be_nil
      end
    end

    context 'when accumulator empty' do
      let(:output) { [] }

      it 'adds the default value' do
        callable = instance.dlme_default('default')
        expect(callable.call(nil, output)).to eq(['default'])
      end
    end
  end

  describe '#dlme_gsub' do
    context 'when pattern in string' do
      let(:output) { ['http://value'] }

      it 'substitutes the replacement for the pattern' do
        callable = instance.dlme_gsub('http://', 'dlme-id-')
        expect(callable.call(nil, output)).to eq(['dlme-id-value'])
      end
    end

    context 'when pattern not in string' do
      let(:output) { ['value'] }

      it 'leaves the string as is' do
        callable = instance.dlme_gsub('http://', '')
        expect(callable.call(nil, output)).to eq(['value'])
      end
    end
  end

  describe '#dlme_split' do
    context 'when pattern in string' do
      let(:output) { ['value: other_value'] }

      it 'splits the string into a list on the split pattern' do
        callable = instance.dlme_split(':')
        expect(callable.call(nil, output)).to eq(['value', ' other_value'])
      end
    end

    context 'when pattern not in string' do
      let(:output) { ['value'] }

      it 'prepends the prepend string' do
        callable = instance.dlme_split(':')
        expect(callable.call(nil, output)).to eq(['value'])
      end
    end
  end

  describe '#dlme_strip' do
    context 'when trailing whitespace in string' do
      let(:output) { ['value '] }

      it 'removes the whitespace' do
        callable = instance.dlme_strip
        expect(callable.call(nil, output)).to eq(['value'])
      end
    end

    context 'when leading whitespace in string' do
      let(:output) { [' value'] }

      it 'removes the whitespace' do
        callable = instance.dlme_strip
        expect(callable.call(nil, output)).to eq(['value'])
      end
    end

    context 'when extra whitespace in middle of string' do
      let(:output) { ['value   value'] }

      it 'does not remove the whitespace' do
        callable = instance.dlme_strip
        expect(callable.call(nil, output)).to eq(['value   value'])
      end
    end
  end
end
