# frozen_string_literal: true

require 'stringio'
require 'dlme_json_resource_writer'

RSpec.describe DlmeJsonResourceWriter do
  let(:out) { StringIO.new }
  let(:writer) { described_class.new(settings) }
  let(:settings) { { 'output_stream' => out } }
  let(:context) do
    Struct.new(:output_hash, :logger).new.tap do |str|
      str.output_hash = data
    end
  end

  after do
    out.close
  end

  describe '#put' do
    subject(:put) do
      writer.put(context)
    end

    context 'with invalid data' do
      let(:data) do
        { 'id' => ['one'], 'two' => %w[two1 two2], 'three' => 'three', 'four' => 'four' }
      end

      it 'logs an error' do
        allow(DLME::Utils.logger).to receive(:error)
        put
        expect(DLME::Utils.logger).to have_received(:error)
      end
    end
  end
end
