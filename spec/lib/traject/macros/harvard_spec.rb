# frozen_string_literal: true

# require 'macros/date_parsing'
require 'macros/harvard'
require 'macros/oai'
require 'macros/date_parsing'

RSpec.describe Macros::DateParsing do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
        extend Macros::DateParsing
        extend Macros::Harvard
        extend Macros::OAI
      end
    end
  end

  let(:raw_val_lambda) do
    lambda do |record, accumulator|
      accumulator << record[:raw]
    end
  end

  # -- Specs for general macros follow, alphabetical

  describe '#harvard_ihp_date_range' do
    {
      # these are all from actual data
      '1141 [1728]' => [1728],
      '1288 [1871-72]' => [1871, 1872],
      '1213 [1798 or 1799]' => [1798, 1799],
      '1282 [1865 or 66]' => [1865, 1866],
      '1243 [1827]]' => [1827],
      '1245 [1829 or 30]]' => [1829, 1830],
      '[1908]' => [1908],
      '[1714?]' => [1714],
      # '1313 [1895 or 6]' => [1895, 1896], # not yet -- after https://github.com/sul-dlss/parse_date/issues/33
      # no brackets
      '1284, i.e. 1867]' => [1867],
      '1334' => [1334],
      '1372-1373' => [1372, 1373],
      '1592]' => [1592],
      '1593-' => [1593],
      '17uu-' => (1700..1799).to_a,
      '1880?]' => [1880],
      '189-?]' => (1890..1899).to_a,
      'Dec. 21, 1801' => [1801]
    }.each_pair do |raw_val, expected|
      it "#{raw_val} converts to #{expected}" do
        indexer.to_field('range', raw_val_lambda, indexer.harvard_ihp_date_range)
        expect(indexer.map_record(raw: raw_val)).to include 'range' => expected
      end
    end

    it 'expect uuuu to result in no value' do
      indexer.to_field('range', raw_val_lambda, indexer.harvard_ihp_date_range)
      # 990115019120203941.oai_dc.xml
      expect(indexer.map_record(raw: 'uuuu')).not_to include 'range'
    end

    it 'expect meaningless first val with meaningful second value to use second value' do
      indexer.instance_eval do
        to_field 'range', ->(record, accumulator) { accumulator.replace(record[:values]) }, harvard_ihp_date_range
      end

      # 990073721190203941.oai_dc.xml
      expect(indexer.map_record(values: ['[S.l', '1850?]'])).to include 'range' => [1850]
    end
  end

  describe '#harvard_mods_date_range' do
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
        to_field 'range', harvard_mods_date_range
      end
    end

    context 'when dateCreated element exists' do
      context 'when point attributes available' do
        let(:date_els) do
          '<mods:dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">1825</mods:dateCreated>
          <mods:dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1875</mods:dateCreated>'
        end

        it 'uses end point values for range' do
          expect(indexer.map_record(ng_rec)).to include 'range' => (1825..1875).to_a
        end
      end
      context 'when keyDate attribute but no point attributes' do
        let(:date_els) { '<mods:dateCreated encoding="w3cdtf" keyDate="yes">1123</mods:dateIssued>' }
        it 'uses value for range' do
          expect(indexer.map_record(ng_rec)).to eq('range' => [1123])
        end
      end
    end
  end
end
