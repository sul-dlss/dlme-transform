# frozen_string_literal: true

require 'macros/field_extraction'

RSpec.describe Macros::FieldExtraction do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::FieldExtraction # rubocop:disable RSpec/DescribedClass
        extend TrajectPlus::Macros
      end
    end
  end

  describe '#xpath_multi_lingual_commas_with_prepend' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:ar_val_only_record) do
      <<-XML
        <record>
          <metadata>
            <title>القرآن</title>
          </metadata>
        </record>
      XML
    end
    let(:ar_only) { Nokogiri::XML.parse(ar_val_only_record) }
    let(:latn_val_only_record) do
      <<-XML
        <record>
          <metadata>
            <title>Qur'an</title>
          </metadata>
        </record>
      XML
    end
    let(:latn_only) { Nokogiri::XML.parse(latn_val_only_record) }
    let(:both_vals_record) do
      <<-XML
        <record>
          <metadata>
            <title>القرآن</title>
            <title>Qur'an</title>
          </metadata>
        </record>
      XML
    end
    let(:both) { Nokogiri::XML.parse(both_vals_record) }

    before do
      indexer.instance_eval do
        to_field 'cho_title', xpath_multi_lingual_commas_with_prepend('/record/metadata/title', 'لقب: ', 'Title: ')
      end
    end

    it 'has arabic value only' do
      expect(indexer.map_record(ar_only)).to eq('cho_title' => ['لقب: القرآن'])
    end

    it 'has latin value only' do
      expect(indexer.map_record(latn_only)).to eq('cho_title' => ["Title: Qur'an"])
    end

    it 'has values in both scripts' do
      expect(indexer.map_record(both)).to eq('cho_title' => ['لقب: القرآن', "Title: Qur'an"])
    end
  end
end
