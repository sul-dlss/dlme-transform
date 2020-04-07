# frozen_string_literal: true

require 'macros/dlme'

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

    context 'with no values in accumulator' do
      it 'leaves accumulator empty' do
        accumulator = []
        callable = instance.lang('en')
        expect(callable.call(nil, accumulator, nil)).to eq nil
      end
    end
  end

  describe 'naive_language_extractor' do
    context 'when extracted string contains Arabic characters' do
      it 'returns the correct language value ar-Arab' do
        extracted_string = 'الولايات المتحدة الامريكيه'
        callable = instance.naive_language_extractor
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'ar-Arab', values: [extracted_string] }])
      end
    end

    context 'when extracted string does not contain Arabic characters' do
      it 'returns the default language of english' do
        extracted_string = 'Some extracted string value'
        callable = instance.naive_language_extractor
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'en', values: [extracted_string] }])
      end
    end
  end
end
