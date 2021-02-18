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

  # let(:klass) do
  #   Class.new do
  #     include TrajectPlus::Macros
  #     include Macros::LanguageExtraction
  #   end
  # end
  # let(:instance) { klass.new }

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
