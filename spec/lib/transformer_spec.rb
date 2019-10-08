# frozen_string_literal: true

require 'transformer'

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
        expect(indexer.settings).to include('writer_class_name' => 'Traject::DebugWriter')
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
