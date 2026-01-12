# frozen_string_literal: true

require 'macros/openn'

RSpec.describe Macros::Openn do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::Openn
        extend TrajectPlus::Macros
      end
    end
  end

  describe 'extract_agg_shown_at' do
    # Sample records
    let(:record) { { 'harvest_url' => 'https://openn.library.upenn.edu/Data/0043/mscoll200_bowden/data/mscoll200_bowden_TEI.xml' } }

    before do
      indexer.instance_eval do
        to_field 'agg_is_shown_at', extract_agg_shown_at('harvest_url')
      end
    end

    it 'has a valid url to the resource' do
      expect(indexer.map_record(record)).to eq('agg_is_shown_at' => ['https://openn.library.upenn.edu/Data/0043/html/mscoll200_bowden.html'])
    end
  end

  describe 'extract_preview_url' do
    # Sample records
    let(:record) { { 'harvest_url' => 'https://openn.library.upenn.edu/Data/0043/mscoll200_bowden/data/mscoll200_bowden_TEI.xml', 'preview' => 'thumb/9673_0000_thumb.jpg' } }

    before do
      indexer.instance_eval do
        to_field 'agg_preview', extract_preview_url('harvest_url', 'preview')
      end
    end

    it 'has a valid url to the resource' do
      expect(indexer.map_record(record)).to eq('agg_preview' => ['https://openn.library.upenn.edu/Data/0043/mscoll200_bowden/data/thumb/9673_0000_thumb.jpg'])
    end
  end
end
