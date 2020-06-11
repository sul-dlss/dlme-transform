# frozen_string_literal: true

require 'macros/csic'

RSpec.describe Macros::Csic do
  let(:klass) do
    Class.new do
      include Macros::Csic
    end
  end
  let(:instance) { klass.new }

  describe '#extract_preview' do
    let(:urls1) do
      ['http://aleph.csic.es/imagenes/mad01/0006_PMSC/P_001354598_792189_V00.pdf',
       'http://simurg.bibliotecas.csic.es/viewer/image/CSIC001354598/1/',
       'http://aleph.csic.es/imagenes/mad01/0006_PMSC/html/001354598.html']
    end

    let(:urls2) do
      ['http://aleph.csic.es/imagenes/mad01/0006_PMSC/P_001354598_792189_V00.pdf',
       'http://aleph.csic.es/imagenes/mad01/0006_PMSC/html/001354598.html']
    end

    context 'when a simurg URL 856u exists' do
      it 'returns only the simurg URL record' do
        callable = instance.extract_preview
        expect(callable.call(nil, urls1, nil)).to eq ['http://simurg.bibliotecas.csic.es/viewer/image/CSIC001354598/1/']
      end
    end

    context 'when a simurg URL 856u does not exists' do
      it 'returns only the simurg URL record' do
        callable = instance.extract_preview
        expect(callable.call(nil, urls2, nil)).to eq []
      end
    end

    context 'when no 856u fields exists' do
      it 'returns an empty array' do
        callable = instance.extract_preview
        expect(callable.call(nil, nil, nil)).to eq nil
      end
    end
  end
end
