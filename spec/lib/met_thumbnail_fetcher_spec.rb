# frozen_string_literal: true

require 'met_thumbnail_fetcher'

RSpec.describe MetThumbnailFetcher do
  describe 'fetch' do
    subject { described_class.fetch('12312') }

    let(:response) { instance_double Faraday::Response, body: json, success?: true }

    before do
      allow(DLME::Utils).to receive(:fetch_json)
        .with('https://collectionapi.metmuseum.org/public/collection/v1/objects/12312')
        .and_return(JSON.parse(json))
    end

    context 'when the results are empty' do
      let(:json) do
        '{}'
      end

      it { is_expected.to be nil }
    end

    context 'when there is a thumbnail' do
      let(:json) do
        '{"primaryImage":"http://images.metmuseum.org/images/3"}'
      end

      it { is_expected.to eq 'http://images.metmuseum.org/images/3' }
    end
  end
end
