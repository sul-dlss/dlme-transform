# frozen_string_literal: true

require 'macros/walters'

RSpec.describe Macros::Walters do
  let(:klass) do
    Class.new do
      include Macros::Walters
      include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe 'generate_edm_type' do
    # context 'when classification & object name blank' do
    #   it 'returns nothing' do
    #     classification = ''
    #     object_name = ''
    #
    #     expect(instance.send(:generate_edm_type, classification)).to eq(nil)
    #   end
    # end
    #
    # context 'when classification & object name filled' do
    #   it 'returns classification' do
    #     classification = 'Manuscript'
    #     object_name = 'Text'
    #
    #     expect(instance.send(:generate_edm_type, classification)).to eq('manuscript')
    #   end
    # end
  end
end
