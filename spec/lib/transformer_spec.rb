# frozen_string_literal: true

require 'transformer'

RSpec.describe Dlme::TransformMapper do
  subject(:mapper) do
    described_class.new(mapping_config: mapping_config,
                        base_data_dir: base_data_dir,
                        data_dir: data_dir)
  end

  let(:mapping_config) do
    [
      {
        'paths' => [
          'stanford/maps'
        ],
        'extension' => '.mods',
        'testing_id' => 1
      },
      {
        'paths' => [
          'other/maps'
        ],
        'testing_id' => 2
      }
    ]
  end

  let(:base_data_dir) { 'data' }

  let(:file1) { 'data/stanford/maps/dir1/file1.mods' }
  let(:file2) { 'data/stanford/maps/dir2/file2.mods' }
  let(:file3) { 'data/other/maps/file3.xml' }

  describe '#map' do
    context 'data dir matches a path' do
      let(:data_dir) { 'stanford/maps' }

      before do
        allow(File).to receive(:file?).and_return(false)
        allow(Dir).to receive(:glob).and_return([file1, file2])
      end

      it 'returns the correct mapping' do
        mapping = mapper.map
        expect(mapping.size).to eq(2)
        expect(mapping[file1]['testing_id']).to eq(1)
        expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}")
        expect(Dir).to have_received(:glob).with("#{base_data_dir}/#{data_dir}/**/*.mods")
      end
    end
    context 'data dir is subdirectory of a path' do
      let(:data_dir) { 'stanford/maps/dir1' }

      before do
        allow(File).to receive(:file?).and_return(false)
        allow(Dir).to receive(:glob).and_return([file1])
      end

      it 'returns the correct mapping' do
        mapping = mapper.map
        expect(mapping.size).to eq(1)
        expect(mapping[file1]['testing_id']).to eq(1)
        expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}")
        expect(Dir).to have_received(:glob).with("#{base_data_dir}/#{data_dir}/**/*.mods")
      end
    end
    context 'data dir is parent of multiple path' do
      let(:data_dir) { '' }

      before do
        allow(File).to receive(:file?).and_return(false)
        allow(Dir).to receive(:glob).and_return([file1, file2], [file3])
      end

      it 'returns the correct mapping' do
        mapping = mapper.map
        expect(mapping.size).to eq(3)
        expect(mapping[file1]['testing_id']).to eq(1)
        expect(mapping[file3]['testing_id']).to eq(2)
        expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}").twice
        expect(Dir).to have_received(:glob).with("#{base_data_dir}/stanford/maps/**/*.mods")
        expect(Dir).to have_received(:glob).with("#{base_data_dir}/other/maps/**/*.xml")
      end
    end
    context 'data dir is a file' do
      let(:data_dir) { 'stanford/maps/dir1/file1.mods' }

      before do
        allow(File).to receive(:file?).and_return(true)
      end

      it 'returns the correct mapping' do
        mapping = mapper.map
        puts(mapping)
        expect(mapping.size).to eq(1)
        expect(mapping[file1]['testing_id']).to eq(1)
        expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}")
      end
    end
  end
end
