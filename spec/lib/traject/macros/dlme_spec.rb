# frozen_string_literal: true

require 'macros/dlme'
require 'macros/string_helper'

RSpec.describe Macros::DLME do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::DLME
        extend Macros::StringHelper
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

  describe '#default' do
    it 'returns a Proc' do
      expect(instance.default('Untitled', 'بدون عنوان')).to be_a(Proc)
    end

    context 'with no values in accumulator' do
      it 'replaces accumulator with default value' do
        accumulator_original = []
        callable = instance.default('Untitled', 'بدون عنوان')
        expect(callable.call(nil, accumulator_original)).to eq(
          [{ language: 'en', values: ['Untitled'] }, { language: 'ar-Arab', values: ['بدون عنوان'] }]
        )
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
        expect(callable.call(nil, accumulator, nil)).to eq nil
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
      let(:title) { '<title><title>' }

      it 'has title provided a value' do
        expect(indexer.map_record(ng_rec)).to eq({})
      end
    end

    context 'when value present' do
      let(:title) { '<title>Title<title>' }

      it 'has title provided a value' do
        expect(indexer.map_record(ng_rec)).to eq('cho_title' => ['Prepended Title'])
      end
    end
  end

  describe '#xpath_title_or_desc' do
    let(:title_only_record) do
      <<-XML
        <record>
          <metadata>
            <title>Qur'an</title>
          </metadata>
        </record>
      XML
    end
    let(:title_only) { Nokogiri::XML.parse(title_only_record) }
    let(:desc_only_record) do
      <<-XML
        <record>
          <metadata>
            <description>Arabic Manuscript</descritpion>
          </metadata>
        </record>
      XML
    end
    let(:desc_only) { Nokogiri::XML.parse(desc_only_record) }
    let(:neither_record) do
      <<-XML
        <record xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <metadata>
            <dc
              xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
              <dc:type>Manuscripts</dc:type>
            <dc>
          </metadata>
        </record>
      XML
    end
    let(:neither) { Nokogiri::XML.parse(neither_record) }

    before do
      indexer.instance_eval do
        to_field 'cho_title', xpath_title_or_desc('/record/metadata/title', '/record/metadata/description')
      end
    end

    it 'has title provided a value' do
      expect(indexer.map_record(title_only)).to eq('cho_title' => ["Qur'an"])
    end

    it 'has description but no title' do
      expect(indexer.map_record(desc_only)).to eq('cho_title' => ['Arabic Manuscript'])
    end

    it 'has neither title nor description' do
      expect(indexer.map_record(neither)).to eq({})
    end
  end
end
