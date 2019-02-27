# frozen_string_literal: true

RSpec.describe 'not_found translation map' do
  let(:translation) do
    indexer = Traject::Indexer.new
    this = self
    indexer.configure do
      to_field 'cho_language', literal(this.key), translation_map('not_found', 'marc_languages')
    end
    indexer.map_record(nil)['cho_language']
  end

  context 'for a found key' do
    let(:key) { 'eng' }

    it 'translates a found item' do
      expect(translation).to eq(['English'])
    end
  end

  context 'for a not found key' do
    let(:key) { 'foo' }
    it 'returns the key and NOT FOUND' do
      expect(translation).to eq(['NOT FOUND', key])
    end
  end
end
