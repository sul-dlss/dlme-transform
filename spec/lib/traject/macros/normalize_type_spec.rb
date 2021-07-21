# frozen_string_literal: true

require 'macros/normalize_type'

RSpec.describe Macros::NormalizeType do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
        extend Macros::NormalizeType # rubocop:disable RSpec/DescribedClass described_class doesn't seem to work from in the instance_eval
      end
    end
  end

  describe '#normalize_has_type' do
    let(:record) do
      ['amulet fragment', 'animal bone', 'archival file', 'spindle', 'die', 'tetrapod vessel']
    end
    let(:json_record) { record.to_json }

    before do
      json_list_merge_lambda = lambda do |record, accumulator|
        accumulator.concat Array(JSON.parse(record))
      end

      indexer.instance_eval do
        to_field 'cho_has_type', json_list_merge_lambda, normalize_has_type
      end
    end

    it "removes elements that match '[O|o]ther *' if there are more specific elements" do
      expect(indexer.map_record(json_record)).to eq 'cho_has_type' => ['Amulets', 'Tools & Equipment', 'Recreational Artifacts', 'Containers']
    end

    context 'when accumulator contains no specific types' do
      let(:record) { ['animal bone', 'painting & drawing', 'gravür'] }

      it 'passes through the types that are available' do
        expect(indexer.map_record(json_record)).to eq 'cho_has_type' => ['Other Objects', 'Other Images', 'Other Images']
      end
    end
  end
end
