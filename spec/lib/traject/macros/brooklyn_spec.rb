# frozen_string_literal: true

require 'macros/brooklyn'

RSpec.describe Macros::Brooklyn do
  let(:klass) do
    Class.new do
      include Macros::Brooklyn
      include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe 'brooklyn_collection_id' do
    subject(:macro) { instance.send(:brooklyn_collection_id).call(record, accumulator) }

    let(:accumulator) { [] }

    context 'when field is present' do
      let(:record) { { 'collections' => [{ 'folder' => 'some-collection-id' }] } }

      it 'returns value' do
        expect(macro).to eq(['brooklyn-museum-some-collection-id'])
      end
    end
  end

  describe 'brooklyn_rights' do
    subject(:macro) { instance.send(:brooklyn_rights).call(record, accumulator) }

    let(:accumulator) { [] }

    context 'when field is present' do
      let(:record) { { 'rights_type' => { 'public_name' => 'some value' } } }

      it 'returns value' do
        expect(macro).to eq(['some value'])
      end
    end
  end
end
