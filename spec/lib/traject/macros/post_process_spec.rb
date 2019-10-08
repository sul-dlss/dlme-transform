# frozen_string_literal: true

require 'macros/post_process'

RSpec.describe Macros::PostProcess do
  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::PostProcess
    end
  end
  let(:instance) { klass.new }
  let(:mock_context) { Traject::Indexer::Context.new }

  describe '#convert_to_language_hash' do
    subject(:macro) { instance.convert_to_language_hash('cho_title', 'cho_creator') }

    before do
      mock_context.output_hash = output_hash.dup
    end

    context 'when output hash lacks any given fields' do
      let(:output_hash) { { foo: ['bar'] } }

      it 'does not modify the hash' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to eq(output_hash)
      end
    end

    context 'when output hash has string values for given fields' do
      let(:output_hash) { { 'cho_title' => ['title1'] } }

      it 'accumulates values in a hash with "none" key' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to eq('cho_title' => { 'none' => ['title1'] })
      end
    end

    context 'when output hash has hash values for given fields' do
      let(:output_hash) { { 'cho_title' => [{ language: 'en', values: ['title1'] }] } }

      it 'accumulates values in a hash with keys from source hash' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to eq('cho_title' => { 'en' => ['title1'] })
      end
    end
  end
end
