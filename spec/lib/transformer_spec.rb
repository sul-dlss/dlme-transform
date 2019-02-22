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

RSpec.describe Dlme::Transformer do
  subject(:transformer) do
    described_class.new(input_filepath: input_filepath,
                        config_filepaths: config_filepaths,
                        settings: settings,
                        debug_writer: debug_writer)
  end

  let(:input_filepath) { 'data/test.mods' }

  let(:debug_writer) { false }

  let(:settings) { {} }

  let(:config_filepaths) { [] }

  describe '#transformer' do
    context 'when provided with settings' do
      let(:indexer) { transformer.send(:transformer) }

      let(:settings) { { 'agg_provider': 'Stanford' } }

      it 'correctly configures indexer' do
        expect(indexer.settings).to include('agg_provider' => 'Stanford')
        expect(indexer.settings).to include('command_line.filename' => input_filepath)
      end
    end

    context 'when debug_writer' do
      let(:indexer) { transformer.send(:transformer) }

      let(:debug_writer) { true }

      it 'correctly configures indexer' do
        expect(indexer.settings).to include('writer_class_name' => 'DlmeDebugWriter')
      end
    end

    context 'when provided with configurations' do
      let(:mock_indexer) { instance_double(Traject::Indexer) }

      let(:config_filepaths) { ['test_config.rb'] }

      before do
        allow(Traject::Indexer).to receive(:new).and_return(mock_indexer)
        allow(mock_indexer).to receive(:load_config_file)
        allow(mock_indexer).to receive(:settings)
      end

      it 'correctly loads indexer' do
        transformer.send(:transformer)
        expect(mock_indexer).to have_received(:load_config_file).with('test_config.rb')
        expect(mock_indexer).to have_received(:load_config_file).with('lib/record_counter_config.rb')
      end
    end
  end
end
