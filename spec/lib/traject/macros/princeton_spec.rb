# frozen_string_literal: true

require 'macros/princeton'

RSpec.describe Macros::Princeton do
  let(:klass) do
    Class.new do
      include Macros::Princeton
      include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe 'get_title_and_language' do
    context 'when title is in Latin script with a language value' do
      it 'returns the correct language value with latin script' do
        title = 'Some arabic title'
        record_title = { '@value' => title, '@language' => 'ara' }
        expect(instance.send(:get_title_and_language, record_title)).to eq(language: 'ar-Latn', values: [title])
      end
    end

    context 'when title is in Arabic script with a language value' do
      it 'returns the correct language value with arabic script' do
        title = 'الولايات المتحدة الامريكيه'
        record_title = { '@value' => title, '@language' => 'ara' }
        expect(instance.send(:get_title_and_language, record_title)).to eq(language: 'ar-Arab', values: [title])
      end
    end

    context 'when title does not have language value' do
      it 'returns the default language of english' do
        record_title = 'Some title without language'
        expect(instance.send(:get_title_and_language, record_title)).to eq(language: 'en', values: [record_title])
      end
    end
  end

  describe 'map_language_value' do
    context 'when language found in mapping' do
      it 'maps a language to the correct output' do
        record_title = { '@value' => 'Some arabic title', '@language' => 'ara' }
        expect(instance.send(:map_language_value, record_title)).to eq 'ar'
      end
    end

    context 'when language not found in mapping' do
      it 'maps a language to nil' do
        record_title = { '@value' => 'Some bogus title', '@language' => 'bogus' }
        expect(instance.send(:map_language_value, record_title)).to be_nil
      end
    end
  end
end
