# frozen_string_literal: true

require 'macros/language_extraction'
require 'macros/string_helper'

RSpec.describe Macros::LanguageExtraction do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::StringHelper
        extend Macros::LanguageExtraction
        extend TrajectPlus::Macros
        extend TrajectPlus::Macros::JSON
      end
    end
  end

  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::LanguageExtraction
    end
  end
  let(:instance) { klass.new }

  describe 'arabic_script_lang_or_default' do
    context 'when extracted string contains Arabic characters' do
      it 'returns the correct script value arabic_script_lang' do
        extracted_string = 'الولايات المتحدة الامريكيه'
        callable = instance.arabic_script_lang_or_default('ar-Arab', 'en')
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'ar-Arab', values: [extracted_string] }])
      end
    end

    context 'when extracted string contains Arabic characters and an English role' do
      it 'returns the correct script value arabic_script_lang' do
        extracted_string = 'الولايات المتحدة الامريكيه (Copyist)'
        translated_string = 'الولايات المتحدة الامريكيه (الناسخ)'
        callable = instance.arabic_script_lang_or_default('ar-Arab', 'en')
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'ar-Arab', values: [translated_string] }])
      end
    end
  end

  describe 'armenian_script_lang_or_default' do
    # Sample records
    let(:hy_value) { { 'value' => 'վիճակախաղի շահումների խաղարկությունները կայանալու են' } }
    let(:default_value) { { 'value' => 'value in default script' } }
    let(:both_values) { { 'value' => 'վիճակախաղի շահումների խաղարկությունները կայանալու են|value in default script' } }

    before do
      indexer.instance_eval do
        to_field 'field', extract_json('value'), split('|'), armenian_script_lang_or_default('hy-Armn', 'en')
      end
    end

    it 'assigns hy value' do
      expect(indexer.map_record(hy_value)).to eq({ 'field' => [{ language: 'hy-Armn', values: ['վիճակախաղի շահումների խաղարկությունները կայանալու են'] }] })
    end

    it 'assigns default value' do
      expect(indexer.map_record(default_value)).to eq({ 'field' => [{ language: 'en', values: ['value in default script'] }] })
    end

    it 'assigns both value' do
      expect(indexer.map_record(both_values)).to eq({ 'field' => [{ language: 'hy-Armn', values: ['վիճակախաղի շահումների խաղարկությունները կայանալու են'] }, { language: 'en', values: ['value in default script'] }] })
    end
  end

  describe 'hebrew_script_lang_or_default' do
    # Sample records
    let(:he_value) { { 'value' => 'ספר בחכמות הרפואות' } }
    let(:default_value) { { 'value' => 'value in default script' } }
    let(:both_values) { { 'value' => 'ספר בחכמות הרפואות|value in default script' } }

    before do
      indexer.instance_eval do
        to_field 'field', extract_json('value'), split('|'), hebrew_script_lang_or_default('he', 'en')
      end
    end

    it 'assigns he value' do
      expect(indexer.map_record(he_value)).to eq({ 'field' => [{ language: 'he', values: ['ספר בחכמות הרפואות'] }] })
    end

    it 'assigns default value' do
      expect(indexer.map_record(default_value)).to eq({ 'field' => [{ language: 'en', values: ['value in default script'] }] })
    end

    it 'assigns both value' do
      expect(indexer.map_record(both_values)).to eq({ 'field' => [{ language: 'he', values: ['ספר בחכמות הרפואות'] }, { language: 'en', values: ['value in default script'] }] })
    end
  end
end
