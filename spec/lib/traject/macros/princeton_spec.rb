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

  describe 'get_title_language' do
    context 'when language found in mapping' do
      it 'maps a language to the correct output' do
        record_title = { '@title' => 'Some title', '@language' => 'ara' }
        expect(instance.send(:get_title_language, record_title)).to eq 'ar'
      end
    end

    context 'when language not found in mapping' do
      it 'maps a language to the correct output' do
        record_title = { '@title' => 'Some title', '@language' => 'bogus' }
        expect(instance.send(:get_title_language, record_title)).to be_nil
      end
    end
  end
end
