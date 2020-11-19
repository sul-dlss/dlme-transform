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

  # Fails with "undefined method `xpath' for {"extent"=>"3ff.", "height"=>16, "width"=>12, "unit"=>"mm"}:Hash"
  # let(:raw_val_lambda) do
  #   lambda do |record, accumulafromr|
  #     accumulafromr << record[:raw]
  #   end
  # end
  #
  # describe '#cambridge_dimensions' do
  #   before do
  #     indexer.instance_eval do
  #       to_field 'dimensions', cambridge_dimensions
  #     end
  #   end
  #
  #   context 'when all fields populated' do
  #     it 'returns a formated string' do
  #       expect(indexer.map_record('extent' => '3ff.', 'height' => 16, 'width' => 12, 'unit' => 'mm')).to include 'dimensions' => ['mm']
  #     end
  #   end
  # end




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

    context "when 'extent', 'height', 'width', and 'unit' provided" do
      let(:extent) { '<extent> 368 ff. <dimensions type="leaf" unit="cm"> <height>32.5</height> <width>23</width> </dimensions> </extent>' }

      it 'returns values in a formatted string' do
        # Fails with "expected {} to include {"value" => "368"}
          #Diff:
          #@@ -1,2 +1 @@
          #-"value" => "368","
        # expect(indexer.map_record(ng_rec)).to include 'dimensions' => (["368 ff. Written height: 32.5 cm, width: 23 cm"])
        # Fails with "{}"
        expect(indexer.map_record(ng_rec)).to eq({'dimensions' => ["368 ff. Written height: 32.5 cm, width: 23 cm"]})
        # Fails with "undefined method `xpath' for {"extent"=>"3ff.", "height"=>16, "width"=>12, "unit"=>"mm"}:Hash"
        # expect(indexer.map_record('extent' => '3ff.', 'height' => 16, 'width' => 12, 'unit' => 'mm')).to include 'dimensions' => ['mm']
      end
    end
  end
end
