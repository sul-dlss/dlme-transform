# frozen_string_literal: true

require 'macros/csic'

RSpec.describe Macros::Csic do
  subject(:macro_result) { callable.call(nil, urls, nil) }

  let(:callable) { klass.new.extract_preview }
  let(:klass) do
    Class.new do
      include Macros::Csic
    end
  end

  describe '#extract_preview' do
    context 'when a simurg URL exists' do
      let(:urls) do
        [
          'http://aleph.csic.es/imagenes/mad01/0006_PMSC/P_001354598_792189_V00.pdf',
          'http://simurg.bibliotecas.csic.es/viewer/image/CSIC001354598/1/',
          'http://aleph.csic.es/imagenes/mad01/0006_PMSC/html/001354598.html'
        ]
      end

      it 'returns only the simurg URL record(s)' do
        expect(macro_result).to eq ['http://simurg.bibliotecas.csic.es/viewer/image/CSIC001354598/1/']
      end
    end

    context 'when a simurg URL does not exist' do
      let(:urls) do
        [
          'http://aleph.csic.es/imagenes/mad01/0006_PMSC/P_001354598_792189_V00.pdf',
          'http://aleph.csic.es/imagenes/mad01/0006_PMSC/html/001354598.html'
        ]
      end

      it 'returns an empty array' do
        expect(macro_result).to eq []
      end
    end

    context 'when passed a URLs value that is blank (empty, nil)' do
      let(:urls) { nil }

      it 'returns nil' do
        expect(macro_result).to be_nil
      end
    end
  end
end
