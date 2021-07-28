# frozen_string_literal: true

require 'macros/title_extraction'
require 'macros/string_helper'

RSpec.describe Macros::TitleExtraction do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::StringHelper
        extend Macros::TitleExtraction
        extend TrajectPlus::Macros
      end
    end
  end

  describe 'json_title_or' do
    # Sample records
    let(:both_fields) { { 'title' => 'Some title', 'other' => 'Some other field' } }
    let(:only_other) { { 'other' => 'Some other field' } }

    before do
      indexer.instance_eval do
        to_field 'cho_title', json_title_or('title', 'other')
      end
    end

    it 'has title present' do
      expect(indexer.map_record(both_fields)).to eq('cho_title' => ['Some title'])
    end

    it 'has no title but other field present' do
      expect(indexer.map_record(only_other)).to eq('cho_title' => ['Some other field'])
    end
  end

  describe 'json_title_plus' do
    # Sample records
    let(:both_fields) { { 'title' => 'Some title', 'other' => 'Some other field' } }
    let(:only_other) { { 'other' => 'Some other field' } }
    let(:only_title) { { 'title' => 'Some title' } }

    before do
      indexer.instance_eval do
        to_field 'cho_title', json_title_plus('title', 'other')
      end
    end

    it 'has title and other field present' do
      expect(indexer.map_record(both_fields)).to eq('cho_title' => ['Some title Some other field'])
    end

    it 'has other only' do
      expect(indexer.map_record(only_other)).to eq('cho_title' => ['Some other field'])
    end

    it 'has title only' do
      expect(indexer.map_record(only_title)).to eq('cho_title' => ['Some title'])
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
        <record>
          <metadata>
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
