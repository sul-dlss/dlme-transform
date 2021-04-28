# frozen_string_literal: true

require 'macros/version'

RSpec.describe Macros::Version do
  let(:klass) do
    Class.new do
      include Macros::Version
    end
  end
  let(:instance) { klass.new }

  describe '#version' do
    let(:version) { '8bb2a18' }

    it 'returns a github hash key from the environment' do
      allow(ENV).to receive(:fetch).and_return(version)
      callable = instance.version
      expect(callable.call(nil, [])).to eq([version])
    end
  end
end
