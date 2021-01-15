# frozen_string_literal: true

require 'macros/bodleian'

RSpec.describe Macros::Bodleian do
  let(:klass) do
    Class.new do
      include Macros::Bodleian
      include TrajectPlus::Macros
    end
  end
  let(:instance) { klass.new }

  describe 'title' do
    subject { instance.send(:get_arabic_title, record) }

    let(:record) { { 'title' => 'Nuzhat al-mushtāq fī ikhtirāq al-āfāq'} }

    context 'when title contians does not contain Arabic script' do
      it { is_expected.to_eq 'Nuzhat al-mushtāq fī ikhtirāq al-āfāq' }
    end
  end
end
