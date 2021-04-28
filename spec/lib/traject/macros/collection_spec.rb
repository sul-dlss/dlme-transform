# frozen_string_literal: true

require 'macros/collection'

RSpec.describe Macros::Collection do
  let(:klass) do
    Class.new do
      include Macros::Collection
    end
  end
  let(:instance) { klass.new }

  describe '#collection' do
    let(:collection) { 'stanford/maps' }
    let(:input_name) { 'data/stanford/maps/file_1.xml' }

    it 'returns a path string that cooresponds to a collection' do
      context = {}
      allow(context).to receive(:input_name).and_return(input_name)
      callable = instance.collection
      expect(callable.call(nil, [], context)).to eq([collection])
    end
  end
end
