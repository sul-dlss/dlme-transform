# frozen_string_literal: true

require 'macros/language_extraction'

RSpec.describe Macros::LanguageExtraction do
  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::LanguageExtraction
    end
  end
  let(:instance) { klass.new }

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
