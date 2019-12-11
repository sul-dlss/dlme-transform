# frozen_string_literal: true

require 'macros/iiif'

RSpec.describe Macros::IIIF do
  let(:klass) do
    Class.new do
      include Macros::IIIF
    end
  end
  let(:instance) { klass.new }
  let(:fixture_file_path) { File.join('./spec/fixtures/fr426cg9537.json') }
  let(:iiif_json) { JSON.parse(File.open(fixture_file_path).read) }

  describe '#iiif_thumbnail_id' do
    subject(:iiif_thumbnail_id) { instance.iiif_thumbnail_id(iiif_json) }
    let(:thumb_id) do
      'https://stacks.stanford.edu/image/iiif/fr426cg9537%2FSC1094_s3_b14_f17_Cats_1976_0005/full/!400,400/0/default.jpg'
    end

    context 'when a iiif thumbnail id exists in the manifest' do
      it 'returns the thumbnail id' do
        expect(iiif_thumbnail_id).to eq(thumb_id)
      end
    end
  end

  describe 'iiif_thumbnail_service_id' do
    subject(:iiif_thumbnail_service_id) { instance.iiif_thumbnail_service_id(iiif_json) }
    let(:thumb_service_id) { 'https://stacks.stanford.edu/image/iiif/fr426cg9537%2FSC1094_s3_b14_f17_Cats_1976_0005' }

    context 'when a iiif thumbnail service id exists in the manifest' do
      it 'returns the thumbnail service id' do
        expect(iiif_thumbnail_service_id).to eq(thumb_service_id)
      end
    end
  end

  describe 'iiif_thumbnail_service_protocol' do
    subject(:iiif_thumbnail_service_protocol) { instance.iiif_thumbnail_service_protocol(iiif_json) }
    let(:thumb_service_protocol) { 'http://iiif.io/api/image/2/level2.json' }

    context 'when a iiif thumbnail service protocol exists in the manifest' do
      it 'returns the thumbnail service protocol' do
        expect(iiif_thumbnail_service_protocol).to eq(thumb_service_protocol)
      end
    end
  end

  describe 'iiif_thumbnail_service_conforms_to' do
    subject(:iiif_thumbnail_service_conforms_to) { instance.iiif_thumbnail_service_conforms_to(iiif_json) }
    let(:thumb_service_conforms_to) { 'http://iiif.io/api/image/' }

    context 'when a iiif thumbnail service conforms to exists in the manifest' do
      it 'returns the thumbnail service conforms to' do
        expect(iiif_thumbnail_service_conforms_to).to eq(thumb_service_conforms_to)
      end
    end
  end

  describe 'iiif_sequence_id' do
    subject(:iiif_sequence_id) { instance.iiif_sequence_id(iiif_json) }
    let(:manifest_sequence_id) do
      'https://stacks.stanford.edu/image/iiif/fr426cg9537%2FSC1094_s3_b14_f17_Cats_1976_0005/full/full/0/default.jpg'
    end

    context 'when a iiif sequence id to exists in the manifest' do
      it 'returns the iiif sequence id' do
        expect(iiif_sequence_id).to eq(manifest_sequence_id)
      end
    end
  end

  describe 'iiif_sequence_service_id' do
    subject(:iiif_sequence_service_id) { instance.iiif_sequence_service_id(iiif_json) }
    let(:manifest_sequence_service_id) do
      'https://stacks.stanford.edu/image/iiif/fr426cg9537%2FSC1094_s3_b14_f17_Cats_1976_0005'
    end

    context 'when a iiif sequence service id to exists in the manifest' do
      it 'returns the iiif sequence service id' do
        expect(iiif_sequence_service_id).to eq(manifest_sequence_service_id)
      end
    end
  end

  describe 'iiif_sequence_service_protocol' do
    subject(:iiif_sequence_service_protocol) { instance.iiif_sequence_service_protocol(iiif_json) }
    let(:manifest_sequence_service_protocol) { 'http://iiif.io/api/image/2/level2.json' }

    context 'when a iiif sequence service protocol to exists in the manifest' do
      it 'returns the iiif sequence service protocol' do
        expect(iiif_sequence_service_protocol).to eq(manifest_sequence_service_protocol)
      end
    end
  end

  describe 'iiif_sequence_service_conforms_to' do
    subject(:iiif_sequence_service_conforms_to) { instance.iiif_sequence_service_conforms_to(iiif_json) }
    let(:manifest_sequence_service_conforms_to) { 'http://iiif.io/api/image/' }

    context 'when a iiif sequence service conforms to to exists in the manifest' do
      it 'returns the iiif sequence service conforms to' do
        expect(iiif_sequence_service_conforms_to).to eq(manifest_sequence_service_conforms_to)
      end
    end
  end
end
