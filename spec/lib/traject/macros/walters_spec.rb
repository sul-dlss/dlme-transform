# frozen_string_literal: true

require 'macros/walters'

RSpec.describe Macros::Walters do
  let(:klass) do
    Class.new do
      include Macros::Walters
      include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe 'generate_has_type' do
    subject(:macro) { instance.send(:generate_has_type).call(record, accumulator, context) }

    let(:accumulator) { [] }
    let(:context) { {} }

    context 'when record is empty' do
      let(:record) { {} }

      it 'returns empty array' do
        expect(macro).to eq([])
      end
    end

    context 'when classification & object name blank' do
      let(:record) { { 'Classification' => '', 'ObjectName' => '' } }

      it 'returns empty array' do
        expect(macro).to eq([])
      end
    end

    context 'classification is present' do
      let(:record) { { 'Classification' => 'Manuscript', 'ObjectName' => '' } }

      it 'returns classification value downcased' do
        expect(macro).to eq(['manuscript'])
      end
    end

    context 'classification is blank and object name is present' do
      let(:record) { { 'Classification' => '', 'ObjectName' => 'Text' } }

      it 'returns object name value downcased' do
        expect(macro).to eq(['text'])
      end
    end
  end

  describe 'generate_object_date' do
    subject(:macro) { instance.send(:generate_object_date).call(record, accumulator, context) }

    let(:accumulator) { [] }
    let(:context) { {} }

    context 'begin and end date both blank' do
      let(:record) { { 'DateBeginYear' => '', 'DateEndYear' => '' } }

      it 'returns empty array' do
        expect(macro).to eq([nil])
      end
    end

    context 'begin and end date both present' do
      let(:record) { { 'DateBeginYear' => '1920', 'DateEndYear' => '1930' } }

      it 'returns year range as string' do
        expect(macro).to eq(['1920 - 1930'])
      end
    end

    context 'begin date present and end date blank' do
      let(:record) { { 'DateBeginYear' => '1920', 'DateEndYear' => '' } }

      it 'returns begin date as string' do
        expect(macro).to eq(['1920'])
      end
    end

    context 'end date present and begin date blank' do
      let(:record) { { 'DateBeginYear' => '', 'DateEndYear' => '1930' } }

      it 'returns end date as string' do
        expect(macro).to eq(['1930'])
      end
    end
  end

  describe 'generate_preview' do
    subject(:macro) { instance.send(:generate_preview).call(record, accumulator, context) }

    let(:accumulator) { [] }
    let(:context) { {} }

    context 'thumbnail url present' do
      let(:record) { { 'PrimaryImage' => { 'Medium' => 'www.image_url.com' }, 'Images' => '' } }

      it 'returns thumbnail url' do
        expect(macro).to eq(['www.image_url.com'])
      end
    end

    context 'thumbnail url blank but images present' do
      let(:record) { { 'PrimaryImage' => {}, 'Images' => '365jpg' } }

      it 'builds thumbnail url' do
        expect(macro).to eq(['https://art.thewalters.org/images/art/thumbnails/s_365.jpg'])
      end
    end
  end
end
