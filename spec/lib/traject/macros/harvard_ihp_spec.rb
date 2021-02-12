# frozen_string_literal: true

# require 'macros/date_parsing'
require 'macros/harvard_ihp'
require 'macros/oai'
require 'macros/date_parsing'

RSpec.describe Macros::HarvardIHP do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
        extend Macros::DateParsing
        extend Macros::HarvardIHP
        extend Macros::OAI
      end
    end
  end

  let(:raw_val_lambda) do
    lambda do |record, accumulator|
      accumulator << record[:raw]
    end
  end

  describe '#ihp_date_range' do
    let(:record) do
      <<-XML
        <mods:mods xmlns:mods="http://www.loc.gov/mods/v3" version="3.4">
          <mods:originInfo>
            #{date_els}
          </mods:originInfo>
        </mods:mods>
      XML
    end
    let(:ng_rec) { Nokogiri::XML.parse(record) }

    before do
      indexer.instance_eval do
        to_field 'range', ihp_date_range
      end
    end

    context 'when dateCreated element exists' do
      context 'when point attributes available' do
        let(:date_els) do
          '<mods:dateCreated qualifier="approximate">1825</mods:dateCreated>'
        end

        it 'uses end point values for range' do
          expect(indexer.map_record(ng_rec)).to eq 'range' => [1825]
        end
      end
    end
  end
end
