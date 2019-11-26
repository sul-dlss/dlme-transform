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

    context 'when output hash has empty values for given fields' do
      let(:output_hash) { { 'cho_title' => [] } }

      it 'does not accumulate values in the hash' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to eq('cho_title' => {})
      end
    end
  end

  describe '#add_cho_type_facet' do
    subject(:macro) { instance.add_cho_type_facet }

    before do
      mock_context.output_hash = output_hash.dup
    end

    context 'when cho_edm_type and cho_has_type each have values for mult languages' do
      let(:output_hash) do
        {
          'cho_edm_type' => { 'en' => ['Sound'], 'ar-Arab' => ['صوت'] },
          'cho_has_type' => { 'en' => ['Interview'], 'ar-Arab' => ['مقابلة'] }
        }
      end

      it 'creates values for each language' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to include('cho_type_facet' => { 'en' => ['Sound', 'Sound:Interview'],
                                                                          'ar-Arab' => ['صوت', 'صوت:مقابلة'] })
      end
    end

    context 'when cho_edm_type and cho_has_type each have values for language "none"' do
      let(:output_hash) do
        {
          'cho_edm_type' => { 'none' => ['Sound'] },
          'cho_has_type' => { 'none' => ['Interview'] }
        }
      end

      it 'creates value for "none" language' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to include('cho_type_facet' => { 'none' => ['Sound', 'Sound:Interview'] })
      end
    end

    context 'when cho_edm_type has a value for langs and cho_has_type does not have values' do
      let(:output_hash) do
        {
          'cho_edm_type' => { 'en' => ['Sound'], 'ar-Arab' => ['صوت'] }
        }
      end

      it 'creates single level value for each language in cho_edm_type' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to include('cho_type_facet' => { 'en' => ['Sound'],
                                                                          'ar-Arab' => ['صوت'] })
      end
    end

    context 'when cho_edm_type does not have a value for a lang and cho_has_type does have a value' do
      let(:output_hash) do
        {
          'cho_edm_type' => { 'none' => ['Sound'] },
          'cho_has_type' => { 'en' => ['Interview'], 'ar-Arab' => ['مقابلة'] }
        }
      end

      it 'creates single level value for each language in cho_edm_type' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).to include('cho_type_facet' => { 'none' => ['Sound'] })
      end
    end

    context 'when no cho_edm_type but cho_has_type does have values' do
      let(:output_hash) do
        {
          'cho_has_type' => { 'en' => ['Interview'], 'ar-Arab' => ['مقابلة'] }
        }
      end

      it 'does not add field' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).not_to include('cho_type_facet')
      end
    end

    context 'when no cho_edm_type or cho_has_type' do
      let(:output_hash) { {} }

      it 'does not add field' do
        macro.call(nil, mock_context)
        expect(mock_context.output_hash).not_to include('cho_type_facet')
      end
    end
  end
end
