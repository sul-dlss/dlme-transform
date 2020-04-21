# frozen_string_literal: true

RSpec.describe Dlme::CLI::Transform do
  subject(:cli) { described_class.new }

  describe '#transform' do
    let(:config) do
      {
        'trajects' => ['stanford_mods_config.rb'],
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
    let(:traject_dir) { 'traject_configs' }
    let(:traject_config_filepath) { 'traject_configs/stanford_mods_config.rb' }
    let(:mock_file) { instance_double(File, 'summary') }
    let(:data_dir) { 'stanford/record.mods' }
    let(:summary_filepath) { 'summary.json' }

    context 'with defaults' do
      before do
        allow(Dlme::ConfigFinder).to receive(:for).and_return(transform_map)
        allow(Dlme::Transformer).to receive(:new).and_return(mock_transformer)
        allow(mock_transformer).to receive(:transform)
        allow(File).to receive(:read).and_return(metadata_mapping)
        allow(File).to receive(:open).and_yield(mock_file)
        allow(cli).to receive(:options).and_return(mapping_file: metadata_mapping_filepath,
                                                   base_data_dir: base_data_dir,
                                                   data_dir: data_dir,
                                                   traject_dir: traject_dir,
                                                   summary_filepath: summary_filepath,
                                                   debug_writer: nil)
        allow(mock_file).to receive(:puts)
        # Test assumes RecordCounter count is 0. Create that condition in case other
        # tests have incremented the counter
        Dlme::RecordCounter.instance.send(:reset!)
        Dlme::RecordCounter.instance.increment
        Dlme::RecordCounter.instance.increment
      end

      it 'calls transformer mapper and transformer' do
        cli.transform
        expect(File).to have_received(:open).with(summary_filepath, 'w')
        expect(Dlme::Transformer).to have_received(:new)
          .with(input_filepath: file1,
                config_filepaths: [traject_config_filepath],
                settings: config['settings'],
                debug_writer: nil)
        expect(Dlme::Transformer).to have_received(:new)
          .with(input_filepath: file2,
                config_filepaths: [traject_config_filepath],
                settings: config['settings'],
                debug_writer: nil)
        expect(mock_transformer).to have_received(:transform).twice
        expect(mock_file).to have_received(:puts)
          .with(start_with "{\"success\":true,\"records\":2,\"data_path\":\"#{data_dir}\"")
      end
    end
  end
end
