# frozen_string_literal: true

require 'macros/met_csv'
require 'macros/dlme'
require 'csv'
require 'traject_plus'
require 'met_thumbnail_fetcher'

RSpec.describe Macros::MetCsv do
  let(:klass) do
    Class.new do
      include Macros::MetCsv
      include TrajectPlus::Macros
      include Traject::Macros::Basic # for literal()
    end
  end
  let(:instance) { klass.new }

  describe 'met_thumbnail' do
    subject(:extractor) { instance.met_thumbnail }

    let(:accum) { [] }
    let(:source_record) { instance_double(CSV::Row) }
    let(:context) do
      instance_double(Traject::Indexer::Context,
                      output_hash: { 'id' => ['12312'] },
                      source_record: source_record)
    end

    before do
      allow(MetThumbnailFetcher).to receive(:fetch)
        .with('12312')
        .and_return(thumbnail_url)
      extractor.call(nil, accum, context)
    end

    context 'when there is no thumbnail' do
      let(:thumbnail_url) { nil }

      it 'sets the value' do
        expect(accum).to eq []
      end
    end

    context 'when there is a thumbnail' do
      let(:thumbnail_url) { 'http://images.metmuseum.org/images/3' }

      it 'sets the value' do
        expect(accum).to eq [{ 'wr_id' => ['http://images.metmuseum.org/images/3'] }]
      end
    end
  end

  describe 'artist_role_bio' do
    subject { instance.artist_role_bio(row) }

    let(:row) { { 'Artist Begin Date' => '', 'Artist End Date' => '' } }

    context 'when artist role and bio are blank' do
      it { is_expected.to be_empty }
    end
  end
end
