# frozen_string_literal: true

require 'config_finder'

RSpec.describe Dlme::ConfigFinder do
  subject(:configs) do
    described_class.for(mapping_file: mapping_file,
                        base_data_dir: base_data_dir,
                        data_dir: data_dir,
                        sample: sample)
  end

  let(:mapping_config) do
    [
      {
        'paths' => [
          'aims'
        ],
        'extension' => '.csv',
        'testing_id' => 1
      },
      {
        'paths' => [
          'other/maps'
        ],
        'extension' => '.json',
        'testing_id' => 2
      }
    ]
  end
  let(:mapping_file) { 'config/metadata_mapping.json' }
  let(:base_data_dir) { 'spec/fixtures/source_data' }
  # rubocop:disable RSpec/IndexedLet
  let(:file1) { 'data_first_10.csv' }
  let(:file2) { 'data_first_10.json' }
  let(:file3) { 'data/other/maps/file3.xml' }
  # rubocop:enable RSpec/IndexedLet
  let(:sample) { false }

  before do
    allow(JSON).to receive(:parse).and_return(mapping_config)
  end

  context 'when there are no matches' do
    let(:data_dir) { 'aims/file3.csv' }

    it 'raises an error' do
      expect { configs }.to raise_error 'File not found: aims/file3.csv in spec/fixtures/source_data'
    end
  end

  context 'when the data dir matches a path' do
    let(:data_dir) { 'aims' }

    before do
      allow(File).to receive(:file?).and_return(false)
      allow(Dir).to receive(:glob).and_return([file1, file2])
    end

    it 'returns the correct mapping' do
      expect(configs.size).to eq(2)
      expect(configs[file1]['testing_id']).to eq(1)
      expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}")
      expect(Dir).to have_received(:glob).with("#{base_data_dir}/#{data_dir}/**/*.csv")
    end
  end

  context 'data dir is subdirectory of a path' do
    let(:data_dir) { 'aims/aco' }

    before do
      allow(File).to receive(:file?).and_return(false)
      allow(Dir).to receive(:glob).and_return([file1])
    end

    it 'returns the correct mapping' do
      expect(configs.size).to eq(1)
      expect(configs[file1]['testing_id']).to eq(1)
      expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}")
      expect(Dir).to have_received(:glob).with("#{base_data_dir}/#{data_dir}/**/*.csv")
    end
  end

  context 'data dir is parent of multiple paths' do
    let(:data_dir) { '' }

    before do
      allow(File).to receive(:file?).and_return(false)
      allow(Dir).to receive(:glob).and_return([file1, file2], [file3])
    end

    it 'returns the correct mapping' do
      expect(configs.size).to eq(3)
      expect(configs[file1]['testing_id']).to eq(1)
      expect(configs[file3]['testing_id']).to eq(2)
      expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}").twice
      expect(Dir).to have_received(:glob).with("#{base_data_dir}/aims/**/*.csv")
      expect(Dir).to have_received(:glob).with("#{base_data_dir}/other/maps/**/*.json")
    end

    context 'when sample attr is true' do
      let(:sample) { true }

      it 'returns the correct mapping size' do
        expect(configs.size).to eq(2)
      end
    end
  end

  context 'data dir is a file' do
    let(:data_dir) { 'aims/data/data_first_10.csv' }
    let(:file_path) { "#{base_data_dir}/#{data_dir}" }

    before do
      allow(File).to receive(:file?).and_return(true)
      allow(Dir).to receive(:glob).and_return([file1])
    end

    it 'returns the correct mapping' do
      expect(configs.size).to eq(1)
      expect(configs[file_path]['testing_id']).to eq(1)
      expect(File).to have_received(:file?).with("#{base_data_dir}/#{data_dir}")
    end
  end
end
