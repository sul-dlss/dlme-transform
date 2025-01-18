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

  describe 'title_or' do
    # Sample records
    let(:both_fields) { { 'title' => 'Some title', 'other' => 'Some other field' } }
    let(:only_other) { { 'other' => 'Some other field' } }

    before do
      indexer.instance_eval do
        to_field 'cho_title', title_or('title', 'other')
      end
    end

    it 'has title present' do
      expect(indexer.map_record(both_fields)).to eq('cho_title' => ['Some title'])
    end

    it 'has no title but other field present' do
      expect(indexer.map_record(only_other)).to eq('cho_title' => ['Some other field'])
    end
  end

  describe 'title_plus' do
    # Sample records
    let(:both_fields) { { 'title' => 'Some title', 'other' => 'Some other field' } }
    let(:only_other) { { 'other' => 'Some other field' } }
    let(:only_title) { { 'title' => 'Some title' } }

    before do
      indexer.instance_eval do
        to_field 'cho_title', title_plus('title', 'other')
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

  describe 'title_plus_default' do
    # Sample records
    let(:both_fields) { { 'title' => 'Some title', 'other' => 'Some other field' } }
    let(:only_other) { { 'other' => 'Some other field' } }
    let(:only_title) { { 'title' => 'Some title' } }

    before do
      indexer.instance_eval do
        to_field 'cho_title', title_plus_default('title', 'other', 'Untitled')
      end
    end

    it 'has title and other field present' do
      expect(indexer.map_record(both_fields)).to eq('cho_title' => ['Some title Some other field'])
    end

    it 'has other only' do
      expect(indexer.map_record(only_other)).to eq('cho_title' => ['Untitled Some other field'])
    end

    it 'has title only' do
      expect(indexer.map_record(only_title)).to eq('cho_title' => ['Some title'])
    end
  end
end
