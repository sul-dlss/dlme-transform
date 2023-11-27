# frozen_string_literal: true

require 'macros/newcastle'

RSpec.describe Macros::Newcastle do
  let(:klass) do
    Class.new do
      include Macros::Newcastle
      # include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe 'newcastle_thumbnail' do
    subject(:macro) { instance.send(:get_newcastle_thumbnail).call(record, accumulator) }

    let(:accumulator) { [] }

    context 'when field is present' do
      let(:record) { { '.iiif_manifest' => 'https://cdm21051.contentdm.oclc.org/iiif/info/p21051coll46/11296/manifest.json' } }

      it 'returns value' do
        expect(macro).to eq(['https://cdm21051.contentdm.oclc.org/iiif/2/p21051coll46:11298/full/!400,400/0/default.jpg'])
      end
    end
  end
end
