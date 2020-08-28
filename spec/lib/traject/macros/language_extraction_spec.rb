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

  describe 'arabic_or_none' do
    context 'when extracted string contains Arabic characters' do
      it 'returns the correct language value ar-Arab' do
        extracted_string = 'الولايات المتحدة الامريكيه'
        callable = instance.arabic_or_none
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'ar-Arab', values: [extracted_string] }])
      end
    end

    context 'when extracted string does not contain Arabic characters' do
      it 'returns the default language of none' do
        extracted_string = 'Some extracted string value'
        callable = instance.arabic_or_none
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'none', values: [extracted_string] }])
      end
    end
  end

  describe 'arabic_or_und_latn' do
    context 'when extracted string contains Arabic characters' do
      it 'returns the correct language value ar-Arab' do
        extracted_string = 'الولايات المتحدة الامريكيه'
        callable = instance.arabic_or_und_latn
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'ar-Arab', values: [extracted_string] }])
      end
    end

    context 'when extracted string does not contain Arabic characters' do
      it 'returns the default language of und-Latn' do
        extracted_string = 'Some extracted string value'
        callable = instance.arabic_or_und_latn
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'und-Latn', values: [extracted_string] }])
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
      it 'returns the default language of en' do
        extracted_string = 'Some extracted string value'
        callable = instance.naive_language_extractor
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'en', values: [extracted_string] }])
      end
    end
  end

  describe 'persian_or_none' do
    context 'when extracted string contains Arabic characters' do
      it 'returns the correct language value fa-Arab' do
        extracted_string = 'رساله معىنيه در علم هيئت'
        callable = instance.persian_or_none
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'fa-Arab', values: [extracted_string] }])
      end
    end

    context 'when extracted string does not contain Arabic characters' do
      it 'returns the default language of none' do
        extracted_string = 'Some extracted string value'
        callable = instance.persian_or_none
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'none', values: [extracted_string] }])
      end
    end
  end

  describe 'und_arabic_or_syriac' do
    context 'when extracted string contains Arabic characters' do
      it 'returns the correct language value und-Arab' do
        extracted_string = 'الولايات المتحدة الامريكيه'
        callable = instance.und_arabic_or_syriac
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'und-Arab', values: [extracted_string] }])
      end
    end

    context 'when extracted string does not contain Arabic characters' do
      it 'returns the default language of syc' do
        extracted_string = 'Some extracted string value'
        callable = instance.und_arabic_or_syriac
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'syc', values: [extracted_string] }])
      end
    end
  end
end
