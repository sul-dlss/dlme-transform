# frozen_string_literal: true

require 'macros/path_to_file'

RSpec.describe Macros::PathToFile do
  let(:klass) do
    Class.new do
      include Macros::PathToFile
    end
  end
  let(:instance) { klass.new }

  describe '#path_to_file' do
    let(:path_to_file) { 'data/stanford/maps/file_1.xml' }
    let(:input_name) { 'data/stanford/maps/file_1.xml' }

    it 'returns a path string that corresponds to a file' do
      context = {}
      allow(context).to receive(:input_name).and_return(input_name)
      callable = instance.path_to_file
      expect(callable.call(nil, [], context)).to eq([path_to_file])
    end
  end
end
