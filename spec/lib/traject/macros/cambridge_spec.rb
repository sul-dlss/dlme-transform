# frozen_string_literal: true

require 'macros/cambridge'

RSpec.describe Macros::Cambridge do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::Cambridge
        extend TrajectPlus::Macros
      end
    end
  end

  describe '#cambridge_dimensions' do
    let(:record) do
      <<-XML
        <tei:teiHeader xmlns:tei='http://www.tei-c.org/ns/1.0'>
          <tei:fileDesc>
            <tei:sourceDesc>
              <tei:msDesc>
                <tei:physDesc>
                  <tei:objectDesc>
                    <tei:supportDesc>
                      #{extent}
                    </tei:supportDesc
                  </tei:objectDesc>
                </tei:physDesc>
              </tei:msDesc>
            </tei:sourceDesc>
          </tei:fileDesc>
        </tei:teiHeader>
      XML
    end
    let(:ng_rec) { Nokogiri::XML.parse(record) }

    before do
      indexer.instance_eval do
        to_field 'dimensions', cambridge_dimensions
      end
    end

    context 'when all elements and attribute values present' do
      let(:extent) do
        '<tei:extent> 368 ff.<tei:dimensions type="leaf" unit="cm"><tei:height>32.5</tei:height>'\
        '<tei:width>23</tei:width></tei:dimensions></tei:extent>'
      end

      it 'returns values in a formatted string' do
        expect(indexer.map_record(ng_rec)).to eq('dimensions' => ['368 ff. Leaf: (height: 32.5 cm, width: 23 cm)'])
      end
    end

    context 'when multiple instances and all elements and attribute values present' do
      let(:extent) do
        '<tei:extent> 368 ff.<tei:dimensions type="leaf" unit="cm"><tei:height>32.5</tei:height>'\
        '<tei:width>23</tei:width></tei:dimensions><tei:dimensions type="written" unit="cm">'\
        '<tei:height>27</tei:height><tei:width>19</tei:width></tei:dimensions></tei:extent>'
      end

      it 'returns values in a formatted string' do
        expect(indexer.map_record(ng_rec)).to eq('dimensions' => ['368 ff. Leaf: (height: 32.5 cm, width:'\
                                                  ' 23 cm)', 'Written: (height: 27 cm, width: 19 cm)'])
      end
    end

    context 'when one or more elements or attribute missing or empty' do
      let(:extent) do
        '<tei:extent> 368 ff.<tei:dimensions type="leaf" unit="cm"><tei:width>23</tei:width></tei:dimensions></tei:extent>'
      end

      it 'returns an empty hash' do
        expect(indexer.map_record(ng_rec)).to eq({})
      end
    end
  end
end
