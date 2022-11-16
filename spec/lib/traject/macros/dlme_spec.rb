# frozen_string_literal: true

require 'macros/dlme'

RSpec.describe Macros::DLME do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::DLME
        extend TrajectPlus::Macros
      end
    end
  end

  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::DLME
    end
  end
  let(:instance) { klass.new }

  describe '#default_multi_lang' do
    it 'returns a Proc' do
      expect(instance.default_multi_lang('Untitled', 'بدون عنوان')).to be_a(Proc)
    end

    context 'with no values in accumulator' do
      it 'replaces accumulator with default value' do
        accumulator_original = []
        callable = instance.default_multi_lang('Untitled', 'بدون عنوان')
        expect(callable.call(nil, accumulator_original)).to eq(
          [{ language: 'en', values: ['Untitled'] }, { language: 'ar-Arab', values: ['بدون عنوان'] }]
        )
      end
    end
  end

  describe '#at_index' do
    it 'returns a Proc' do
      expect(instance.even_only).to be_a(Proc)
    end

    context 'with values in accumulator' do
      it 'replaces accumulator with values at index passed in parameter' do
        accumulator_original = ['Text', 'Manuscript', 'Object', 'Stelae']
        callable = instance.at_index(1)
        expect(callable.call(nil, accumulator_original)).to eq(['Manuscript'])
      end
    end
  end

  describe '#even_only' do
    it 'returns a Proc' do
      expect(instance.even_only).to be_a(Proc)
    end

    context 'with values in accumulator' do
      it 'replaces accumulator with even values' do
        accumulator_original = ['Text', 'Manuscript', 'Object', 'Stelae']
        callable = instance.even_only
        expect(callable.call(nil, accumulator_original)).to eq(['Text', 'Object'])
      end
    end
  end

  describe '#odd_only' do
    it 'returns a Proc' do
      expect(instance.odd_only).to be_a(Proc)
    end

    context 'with values in accumulator' do
      it 'replaces accumulator with odd values' do
        accumulator_original = ['Text', 'Manuscript', 'Object', 'Stelae']
        callable = instance.odd_only
        expect(callable.call(nil, accumulator_original)).to eq(['Manuscript', 'Stelae'])
      end
    end
  end

  describe '#filter_data_errors' do
    context 'with bad data values found in the accumulator' do
      it 'removes bad values from accumulator' do
        accumulator_original = ['good', 'bad']
        callable = instance.filter_data_errors('bad')
        expect(callable.call(nil, accumulator_original, nil)).to eq(['good'])
      end
    end

    context 'with no bad data values found in the accumulator' do
      it 'returns accumulator unchanged' do
        accumulator_original = ['good', 'also good']
        callable = instance.filter_data_errors('bad')
        expect(callable.call(nil, accumulator_original, nil)).to eq(['good', 'also good'])
      end
    end

    context 'with no values in accumulator' do
      it 'returns empty array' do
        accumulator_original = []
        callable = instance.filter_data_errors('bad')
        expect(callable.call(nil, accumulator_original, nil)).to eq([])
      end
    end
  end

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
      expect(callable.call(nil, accumulator, nil)).to eq([language: 'en', values: accumulator_original])
    end

    context 'with no values in accumulator' do
      it 'leaves accumulator empty' do
        accumulator = []
        callable = instance.lang('en')
        expect(callable.call(nil, accumulator, nil)).to be_nil
      end
    end
  end

  describe '#return_or_prepend' do
    let(:record) do
      <<-XML
        <record>
          <metadata>
            #{title}
          </metadata>
        </record>
      XML
    end
    let(:ng_rec) { Nokogiri::XML.parse(record) }

    before do
      indexer.instance_eval do
        to_field 'cho_title', return_or_prepend('/record/metadata/title', 'Prepended ')
      end
    end

    context 'when value missing' do
      let(:title) { '<title></title>' }

      it 'has title provided a value' do
        expect(indexer.map_record(ng_rec)).to eq({})
      end
    end

    context 'when value present' do
      let(:title) { '<title>Title</title>' }

      it 'has title provided a value' do
        expect(indexer.map_record(ng_rec)).to eq('cho_title' => ['Prepended Title'])
      end
    end
  end
end
