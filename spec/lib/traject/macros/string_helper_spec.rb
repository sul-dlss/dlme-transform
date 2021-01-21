# frozen_string_literal: true

require 'macros/string_helper'

RSpec.describe Macros::StringHelper do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::StringHelper
        extend TrajectPlus::Macros
      end
    end
  end

  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::StringHelper
    end
  end
  let(:instance) { klass.new }

  describe '#squish' do
    it 'returns an Array' do
      string = 'Euchologion ad usum Melchitarum'
      callable = instance.squish
      expect(callable.call(nil, [string])).to be_a(Array)
    end

    context 'when extracted string contains long chunks of whitespace and/or newlines' do
      it 'removes extra whitespace and newlines' do
        string = "Euchologion ad usum Melchitarum,    \n     partim arabice partim syriace,
        cum titulis et rubricis plerumque    \n     mere arabicis, prinicpio       et fine mutilum."
        callable = instance.squish
        expect(callable.call(nil, [string])).to eq(['Euchologion ad usum Melchitarum, partim arabice partim '\
                                                    'syriace, cum titulis et rubricis plerumque mere arabicis, '\
                                                    'prinicpio et fine mutilum.'])
      end
    end
  end

  describe '#titleize' do
    it 'returns an Array' do
      string = 'suchologion ad usum nelchitarum'
      callable = instance.titleize
      expect(callable.call(nil, [string])).to be_a(Array)
    end

    context 'when extracted string in lowercase' do
      it 'titleizes the string' do
        string = 'euchologion ad usum melchitarum'
        callable = instance.titleize
        expect(callable.call(nil, [string])).to eq(['Euchologion Ad Usum Melchitarum'])
      end
    end

    context 'when extracted string in all caps' do
      it 'titleizes the string' do
        string = 'EUCHOLOGION AD USUM MELCHITARUM'
        callable = instance.titleize
        expect(callable.call(nil, [string])).to eq(['Euchologion Ad Usum Melchitarum'])
      end
    end
  end

  describe '#truncate' do
    it 'returns a String' do
      expect(instance.truncate('Euchologion ad usum Melchitarum')).to be_a(String)
    end

    context 'when extracted string longer than 100 charachters' do
      it 'truncates string on first white space after character 100, adds ellipsis' do
        arabic_string = 'تتعلق المراسلات وأوراق أخرى بزيارات قامت بها شخصيات أوروبية وأمريكية إلى '\
        'المملكة العربية السعودية، وتحديدًا إلى الرياض:زيارة في سنة ١٩٣٧قام بها '\
        'المقدم هارولد ريتشارد باتريك ديكسون، الوكيل السياسي السابق في الكويت'
        latin_string = 'Euchologion ad usum Melchitarum, partim arabice partim syriace, cum titulis et rubricis plerumque
        mere arabicis, prinicpio et fine mutilum. Codicem meorat Cyrillus Charon (Korolevski) apud Χρυσοστομικά,
        Romae, 1908, pp. 673 sq. Cf. cod. Vat. ar. 54 ; iisdem notis utimur ac in codice laudato.'
        expect(instance.truncate(arabic_string)).to eq('تتعلق المراسلات وأوراق أخرى بزيارات قامت بها شخصيات '\
          'أوروبية وأمريكية إلى المملكة العربية السعودية...')
        expect(instance.truncate(latin_string)).to eq('Euchologion ad usum Melchitarum, partim arabice partim syriace, '\
          'cum titulis et rubricis plerumque...')
      end
    end

    context 'when extracted string shorter than 100 charachters' do
      it 'returns string without change' do
        arabic_string = 'تتعلق المراسلات وأوراق أخرى'
        latin_string = 'Euchologion ad usum Melchitarum'
        expect(instance.truncate(arabic_string)).to eq('تتعلق المراسلات وأوراق أخرى')
        expect(instance.truncate(latin_string)).to eq('Euchologion ad usum Melchitarum')
      end
    end
  end
end
