# frozen_string_literal: true

require 'macros/met'
require 'traject_plus'

RSpec.describe Macros::Met do
  let(:klass) do
    Class.new do
      include Macros::Met
      include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe 'artist_role_bio' do
    subject { instance.send(:artist_role_bio, record) }

    let(:record) { { 'artistBeginDate' => '', 'artistEndDate' => '' } }

    context 'when artist role and bio are blank' do
      it { is_expected.to be_empty }
    end
  end
end
