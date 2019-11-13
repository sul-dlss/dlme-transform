# frozen_string_literal: true

require 'macros/each_record'

RSpec.describe Macros::EachRecord do
  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::EachRecord
    end
  end
  let(:instance) { klass.new }
  let(:mock_context) { Traject::Indexer::Context.new }

  describe '#add_cho_type_facet' do
    subject(:macro) { instance.add_cho_type_facet }

    before do
      mock_context.output_hash = output_hash.dup
    end

    context 'when cho_edm_type is a Hash (lang specified)' do
      context 'when cho_has_type is a Hash' do
        let(:output_hash) do
          {
            'cho_edm_type' => [{ language: 'en', values: ['Sound'] }, { language: 'ar-Arab', values: ['صوت'] }],
            'cho_has_type' => [{ language: 'en', values: ['Interview'] }, { language: 'ar-Arab', values: ['مقابلة'] }]
          }
        end

        it 'creates values for each language' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).to include('cho_type_facet' => { 'en' => ['Sound:Interview'],
                                                                            'ar-Arab' => ['صوت:مقابلة'] })
        end
      end

      context 'when cho_has_type is an Array' do
        let(:output_hash) do
          {
            'cho_edm_type' => [{ language: 'en', values: ['Sound'] }, { language: 'ar-Arab', values: ['صوت'] }],
            'cho_has_type' => ['bar', 'car']
          }
        end

        it 'creates single level value for each language' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).to include('cho_type_facet' => { 'en' => ['Sound'], 'ar-Arab' => ['صوت'] })
        end
      end

      context 'when no cho_hash_type' do
        let(:output_hash) do
          {
            'cho_edm_type' => [{ language: 'en', values: ['Sound'] }, { language: 'ar-Arab', values: ['صوت'] }]
          }
        end

        it 'creates single level value for each language' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).to include('cho_type_facet' => { 'en' => ['Sound'], 'ar-Arab' => ['صوت'] })
        end
      end
    end

    context 'when cho_edm_type is an Array' do
      context 'when cho_has_type is a Hash' do
        let(:output_hash) do
          {
            'cho_edm_type' => ['foo', 'goo'],
            'cho_has_type' => [{ language: 'en', values: ['Interview'] }, { language: 'ar-Arab', values: ['مقابلة'] }]
          }
        end

        it 'creates single level value for language "none"' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).to include('cho_type_facet' => { 'none' => ['foo'] })
        end
      end
      context 'when cho_has_type is an Array' do
        let(:output_hash) do
          {
            'cho_edm_type' => ['foo', 'goo'],
            'cho_has_type' => ['bar', 'car']
          }
        end

        it 'creates value for language "none"' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).to include('cho_type_facet' => { 'none' => ['foo:bar'] })
        end
      end
      context 'when no cho_hash_type' do
        let(:output_hash) do
          {
            'cho_edm_type' => ['foo', 'goo']
          }
        end

        it 'creates single level value for language "none"' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).to include('cho_type_facet' => { 'none' => ['foo'] })
        end
      end
    end

    context 'when no cho_edm_type' do
      context 'when cho_has_type exists' do
        let(:output_hash) do
          {
            'cho_has_type' => ['bar', 'car']
          }
        end

        it 'creates no value' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).not_to include('cho_type_facet')
        end
      end
      context 'when no cho_hash_type' do
        let(:output_hash) { {} }

        it 'creates no value' do
          macro.call(nil, mock_context)
          expect(mock_context.output_hash).not_to include('cho_type_facet')
        end
      end
    end
  end

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
