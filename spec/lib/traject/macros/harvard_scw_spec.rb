# frozen_string_literal: true

# require 'macros/date_parsing'
require 'macros/harvard_scw'
require 'macros/oai'
require 'macros/date_parsing'

RSpec.describe Macros::HarvardSCW do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
        extend Macros::DateParsing
        extend Macros::HarvardSCW
        extend Macros::OAI
      end
    end
  end

  let(:raw_val_lambda) do
    lambda do |record, accumulator|
      accumulator << record[:raw]
    end
  end

  describe '#scw_has_type' do
    let(:record) do
      <<-XML
        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" version="3.4">
          <mods:typeOfResource>
            #{type}
          </mods:typeOfResource>
          <mods:genre>
            #{genre_one}
          </mods:genre>
          <mods:genre>
            #{genre_two}
          </mods:genre>
          <mods:genre>
            #{genre_three}
          </mods:genre>
        </mods:mods>
      XML
    end
    let(:ng_rec) { Nokogiri::XML.parse(record) }

    before do
      indexer.instance_eval do
        to_field 'has_type', scw_has_type
      end
    end

    context 'when no genre value' do
      let(:type) do
        '<mods:typeOfResource>still image</mods:typeOfResource>'
      end
      let(:genre_one) do
        '<mods:genre></mods:genre>'
      end
      let(:genre_two) do
        '<mods:genre></mods:genre>'
      end
      let(:genre_three) do
        '<mods:genre></mods:genre>'
      end

      it 'returns type value' do
        expect(indexer.map_record(ng_rec)).to eq('has_type' => ['still image'])
      end

      context 'when no type but genre has albums, painting/drawing, album leaf' do
        let(:type) do
          '<mods:typeOfResource></mods:typeOfResource>'
        end
        let(:genre_one) do
          '<mods:genre>albums</mods:genre>'
        end
        let(:genre_two) do
          '<mods:genre>painting/drawing</mods:genre>'
        end
        let(:genre_three) do
          '<mods:genre>album leaf</mods:genre>'
        end

        it 'returns first value found in acceptable_types' do
          expect(indexer.map_record(ng_rec)).to eq('has_type' => ['painting/drawing'])
        end
      end

      context 'when still image is first genre value' do
        let(:type) do
          '<mods:typeOfResource></mods:typeOfResource>'
        end
        let(:genre_one) do
          '<mods:genre>still image</mods:genre>'
        end
        let(:genre_two) do
          '<mods:genre>manuscript</mods:genre>'
        end
        let(:genre_three) do
          '<mods:genre>album leaf</mods:genre>'
        end

        it 'returns other value found in acceptable_types' do
          expect(indexer.map_record(ng_rec)).to eq('has_type' => ['manuscript'])
        end
      end

      context 'when no values' do
        let(:type) do
          '<mods:typeOfResource></mods:typeOfResource>'
        end
        let(:genre_one) do
          '<mods:genre></mods:genre>'
        end
        let(:genre_two) do
          '<mods:genre></mods:genre>'
        end
        let(:genre_three) do
          '<mods:genre></mods:genre>'
        end

        it 'returns empty hash' do
          expect(indexer.map_record(ng_rec)).to eq({})
        end
      end
    end
  end
end
