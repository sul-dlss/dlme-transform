# frozen_string_literal: true

require 'cli'

RSpec.describe Dlme::CLI::Transform do
  subject(:cli) { described_class.new }

  describe '#transform' do
    let(:mock_transformer_mapper) { instance_double(Dlme::TransformMapper) }
    let(:config) do
      {
        'trajects' => ['mods_config.rb'],
        'settings' => {
          'agg_provider' => 'Stanford Libraries'
        }
      }
    end
    let(:metadata_mapping) { JSON.generate([config]) }
    let(:file1) { 'stanford/maps/obj1.mods' }
    let(:file2) { 'stanford/maps/obj2.mods' }
    let(:transform_map) do
      {
        file1 => config,
        file2 => config
      }
    end
    let(:mock_transformer) { instance_double(Dlme::Transformer) }
    let(:metadata_mapping_filepath) { 'metadata_mapping.json' }
    let(:base_data_dir) { 'data' }
    let(:traject_dir) { 'config' }
    let(:traject_config_filepath) { 'config/mods_config.rb' }

    context 'with defaults' do
      before do
        allow(Dlme::TransformMapper).to receive(:new).and_return(mock_transformer_mapper)
        allow(mock_transformer_mapper).to receive(:map).and_return(transform_map)
        allow(Dlme::Transformer).to receive(:new).and_return(mock_transformer)
        allow(mock_transformer).to receive(:transform)
        allow(File).to receive(:read).and_return(metadata_mapping)
        allow(cli).to receive(:options).and_return(mapping_file: metadata_mapping_filepath,
                                                   base_data_dir: base_data_dir,
                                                   data_dir: '',
                                                   traject_dir: traject_dir)
      end

      it 'calls transformer mapper and transformer' do
        cli.transform
        expect(File).to have_received(:read).with(metadata_mapping_filepath)
        expect(Dlme::TransformMapper).to have_received(:new)
          .with(mapping_config: JSON.parse(metadata_mapping),
                base_data_dir: base_data_dir,
                data_dir: '')
        expect(mock_transformer_mapper).to have_received(:map).once
        expect(Dlme::Transformer).to have_received(:new)
          .with(input_filepath: file1,
                config_filepaths: [traject_config_filepath],
                settings: config['settings'])
        expect(Dlme::Transformer).to have_received(:new)
          .with(input_filepath: file2,
                config_filepaths: [traject_config_filepath],
                settings: config['settings'])
        expect(mock_transformer).to have_received(:transform).twice
      end
    end
  end
end
