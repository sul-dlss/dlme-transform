# frozen_string_literal: true

require 'macros/timestamp'

RSpec.describe Macros::Timestamp do
  let(:klass) do
    Class.new do
      include Macros::Timestamp
    end
  end
  let(:instance) { klass.new }

  describe '#timestamp' do
    let(:time_now) { Time.now }

    it 'returns a timestamp value' do
      allow(Time).to receive(:now).and_return(time_now)
      callable = instance.timestamp
      expect(callable.call(nil, [])).to eq([time_now])
    end
  end
end
