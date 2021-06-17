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
        expect(indexer.map_record(ng_rec)).to eq({})
      end
    end
  end
end
