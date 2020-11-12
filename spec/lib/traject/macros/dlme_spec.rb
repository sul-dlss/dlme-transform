# frozen_string_literal: true

require 'macros/dlme'

RSpec.describe Macros::DLME do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::DLME
        extend TrajectPlus::Macros
      end
    end
  end

  let(:klass) do
    Class.new do
      include TrajectPlus::Macros
      include Macros::DLME
    end
  end
  let(:instance) { klass.new }

  describe '#default' do
    it 'returns a Proc' do
      expect(instance.default('Untitled', 'بدون عنوان')).to be_a(Proc)
    end

    context 'with no values in accumulator' do
      it 'replaces accumulator with default value' do
        accumulator_original = []
        callable = instance.default('Untitled', 'بدون عنوان')
        expect(callable.call(nil, accumulator_original)).to eq(
          [{ language: 'en', values: ['Untitled'] }, { language: 'ar-Arab', values: ['بدون عنوان'] }]
        )
      end
    end
  end

  describe '#lang' do
    context 'with bogus language string' do
      let(:language_string) { 'foobar' }

      it 'raises an exception' do
        expect { instance.lang(language_string) }.to raise_error(/foobar is not an acceptable BCP47 language code/)
      end
    end

    it 'returns a Proc' do
      expect(instance.lang('en')).to be_a(Proc)
    end

    it 'transforms the array of strings into an array of hashes' do
      accumulator_original = %w[value1 value2 value3]
      accumulator = accumulator_original.dup
      callable = instance.lang('en')
      expect(callable.call(nil, accumulator, nil)).to eq([language: 'en', values: accumulator_original])
    end

    context 'with no values in accumulator' do
      it 'leaves accumulator empty' do
        accumulator = []
        callable = instance.lang('en')
        expect(callable.call(nil, accumulator, nil)).to eq nil
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

  describe '#xpath_title_or_desc' do
    let(:title_only_record) do
      <<-XML
        <record>
          <metadata>
            <title>Qur'an</title>
          </metadata>
        </record>
      XML
    end
    let(:title_only) { Nokogiri::XML.parse(title_only_record) }
    let(:desc_only_record) do
      <<-XML
        <record>
          <metadata>
            <description>Arabic Manuscript</descritpion>
          </metadata>
        </record>
      XML
    end
    let(:desc_only) { Nokogiri::XML.parse(desc_only_record) }
    let(:neither_record) do
      <<-XML
        <record xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <metadata>
            <dc
              xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
              <dc:type>Manuscripts</dc:type>
            <dc>
          </metadata>
        </record>
      XML
    end
    let(:neither) { Nokogiri::XML.parse(neither_record) }

    before do
      indexer.instance_eval do
        to_field 'cho_title', xpath_title_or_desc('/record/metadata/title', '/record/metadata/description')
      end
    end

    it 'has title provided a value' do
      expect(indexer.map_record(title_only)).to eq('cho_title' => ["Qur'an"])
    end

    it 'has description but no title' do
      expect(indexer.map_record(desc_only)).to eq('cho_title' => ['Arabic Manuscript'])
    end

    it 'has neither title nor description' do
      expect(indexer.map_record(neither)).to eq({})
    end
  end
end
