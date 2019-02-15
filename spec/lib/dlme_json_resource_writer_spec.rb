require 'stringio'
require 'dlme_json_resource_writer'

RSpec.describe DlmeJsonResourceWriter do
  let(:out) { StringIO.new }
  let(:settings) { { 'output_stream' => out } }
  let(:context) do
    Struct.new(:output_hash, :logger).new.tap do |str|
      str.output_hash = data
    end
  end

  after do
    out.close
  end

  let(:writer) { described_class.new(settings) }

  describe '#put' do
    subject(:put) do
      writer.put(context)
    end

    context 'with invalid data' do
      let(:data) do
        { 'id' => ['one'], 'two' => %w[two1 two2], 'three' => 'three', 'four' => 'four' }
      end
      it 'logs an error' do
        expect { put }.to raise_error(
          /Transform produced invalid data.\n\nThe errors are: {"cho_title"=>\["is missing"\]/
        )
      end
    end
  end
end
