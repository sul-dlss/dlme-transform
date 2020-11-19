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

  describe 'arabic_script_lang_or_default' do
    context 'when extracted string contains Arabic characters' do
      it 'returns the correct script value arabic_script_lang' do
        extracted_string = 'الولايات المتحدة الامريكيه'
        callable = instance.arabic_script_lang_or_default('ar-Arab', 'en')
        expect(callable.call(nil, [extracted_string])).to eq([{ language: 'ar-Arab', values: [extracted_string] }])
      end
    end
  end
end
