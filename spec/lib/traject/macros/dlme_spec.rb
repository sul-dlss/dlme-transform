# frozen_string_literal: true

require 'macros/dlme'
require 'traject_plus'

RSpec.describe Macros::DLME do
  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::DLME
    end
  end
  let(:instance) { klass.new }

  describe '#lang' do
    context 'with bogus language string' do
      let(:language_string) { 'foobar' }

      it 'raises an exception' do
        expect { instance.lang(language_string) }.to raise_error(/foobar is not an acceptable BCP47 language code/)
      end
    end

    it 'returns a Proc' do
      expect(instance.lang('en')).to be_a(Proc)
    end

    it 'transforms the array of strings into an array of hashes' do
      accumulator_original = %w[value1 value2 value3]
      accumulator = accumulator_original.dup
      callable = instance.lang('en')
      expect(callable.call(nil, accumulator, nil)).to eq([{ language: 'en', values: accumulator_original }])
    end
  end
end
