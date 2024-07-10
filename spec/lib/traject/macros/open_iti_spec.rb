# frozen_string_literal: true

require 'macros/open_iti'
require 'rspec'
require 'webmock/rspec'
require 'yaml'

RSpec.describe Macros::OpenITI do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::OpenITI # rubocop:disable RSpec/DescribedClass
        extend TrajectPlus::Macros
      end
    end
  end

  before do
    # Mock the HTTParty call using WebMock
    WebMock.stub_request(:get, 'https://example.com')
           .to_return(body: { 'obj_descr_en' => 'This is the description for a record (English) written by %<author_lat>s' }.to_yaml)
  end

  describe '#object_description' do
    let(:record) do
      {
        'author_ar' => 'Author Name (Arabic)',
        'author_lat' => 'Author Name (English)',
        'text_url' => 'https://example.com/text',
        'one2all_data_url' => 'https://example.com/data',
        'one2all_stats_url' => 'https://example.com/stats',
        'one2all_vis_url' => 'https://example.com/vis',
        'pairwise_data_url' => 'https://example.com/pairwise_data',
        'uncorrected_ocr_ar' => '...',
        'uncorrected_ocr_en' => '...'
      }
    end

    before do
      indexer.instance_eval do
        config = YAML.safe_load_file('spec/fixtures/source_data/openiti/config.yml')
        to_field 'cho_description', object_description(config, 'lat')
      end
    end

    it 'returns the expected description for a record in English' do
      expect(indexer.map_record(record)).to eq('cho_description' => ["Author: Author Name (English)<br/>\n\nMachine-readable text and text reuse datasets (from OpenITI release 2023.1.8).<br/>\n\nMachine-readable text: https://example.com/text<br/>\n\nThe KITAB text reuse datasets (https://kitab-project.org/data#passim-text-reuse-data-sets)\ndocument the overlap between the present work and other texts in the Open Islamicate Texts Initiative corpus.<br/>\n\nDataset documenting the overlap between the present text and the entire OpenITI corpus:\nhttps://example.com/data<br/>\n\nStatistics on the overlap between the present text and all other texts in the OpenITI corpus:\nhttps://example.com/stats<br/>\n\nVisualization of the overlap between the present text and the entire OpenITI corpus:\nhttps://example.com/vis<br/>\n\nDatasets documenting the overlap between the present text and a single other text (“pairwise”):\nhttps://example.com/pairwise_data<br/>\n\n\nFor instructions on batch downloading all of the KITAB and OpenITI data, see\nhttps://kitab-project.org/data/download<br/>\n\nThe KITAB project was funded by the European Research Council (ERC).<br/>\n\n...\n"])
    end
  end
end
