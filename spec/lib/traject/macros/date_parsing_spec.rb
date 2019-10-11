# frozen_string_literal: true

require 'macros/date_parsing'

RSpec.describe Macros::DateParsing do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend TrajectPlus::Macros
        extend Macros::DateParsing
      end
    end
  end

  let(:raw_val_lambda) do
    lambda do |record, accumulator|
      accumulator << record[:raw]
    end
  end

  describe '#array_from_range' do
    before do
      indexer.instance_eval do
        to_field 'int_array', accumulate { |record, *_| record[:value] }, array_from_range
      end
    end

    it 'gets a range of years' do
      expect(indexer.map_record(value: '1880; 1881; 1882; 1883; 1884')).to include 'int_array' => [1880, 1881, 1882, 1883, 1884]
    end

    it 'gets a range of negative years' do
      expect(indexer.map_record(value: '-881; -880; -879; -878; -877')).to include 'int_array' => [-881, -880, -879, -878, -877]
    end

    it 'gets a string' do
      expect(indexer.map_record(value: 'ca. late 19th century')).to be_empty
    end

    it 'gets a nil value' do
      expect(indexer.map_record(value: nil)).to be_empty
    end
  end

  describe '#single_year_from_string' do
    context 'Sun, 12 Nov 2017 14:08:12 +0000' do
      it 'gets 2017' do
        indexer.instance_eval do
          to_field 'int_array', accumulate { |record, *_| record[:value] }, single_year_from_string
        end

        expect(indexer.map_record(value: 'Sun, 12 Nov 2017 14:08:12 +0000')).to include 'int_array' => [2017]
      end
    end
  end

  describe '#range_array_from_positive_4digits_hyphen' do
    before do
      indexer.instance_eval do
        to_field 'int_array', accumulate { |record, *_| record[:value] }, range_array_from_positive_4digits_hyphen
      end
    end

    it 'parseable values' do
      expect(indexer.map_record(value: '2019')).to include 'int_array' => [2019]
      expect(indexer.map_record(value: '2017-2019')).to include 'int_array' => [2017, 2018, 2019]
      expect(indexer.map_record(value: '2017 - 2019')).to include 'int_array' => [2017, 2018, 2019]
      expect(indexer.map_record(value: '2017- 2019')).to include 'int_array' => [2017, 2018, 2019]
    end

    it 'when missing date' do
      expect(indexer.map_record({})).to eq({})
    end
  end

  describe '#american_numismatic_date_range' do
    it 'both dates and range are valid' do
      indexer.to_field('range', raw_val_lambda, indexer.american_numismatic_date_range)
      expect(indexer.map_record(raw: '999|1001')).to include 'range' => [999, 1000, 1001]
      expect(indexer.map_record(raw: '-1001|-999')).to include 'range' => [-1001, -1000, -999]
      expect(indexer.map_record(raw: '999')).to include 'range' => [999]
      expect(indexer.map_record(raw: '999| 1001')).to include 'range' => [999, 1000, 1001]
      expect(indexer.map_record(raw: '999 |1001')).to include 'range' => [999, 1000, 1001]
      expect(indexer.map_record(raw: '-99|1')).to include 'range' => (-99..1).to_a
    end
  end

  describe '#fgdc_date_range' do
    before do
      indexer.instance_eval do
        to_field 'range', fgdc_date_range
      end
    end

    context 'when rngdates element provided' do
      it 'range is from begdate to enddate' do
        rec_str = <<-XML
          <?xml version="1.0" encoding="utf-8" ?>
          <!DOCTYPE metadata SYSTEM "http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd">
          <metadata>
            <idinfo>
              <timeperd>
                <timeinfo>
                  <rngdates>
                    <begdate>19990211</begdate>
                    <enddate>20000222</enddate>
                  </rngdates>
                </timeinfo>
              </timeperd>
            </idinfo>
          </metadata>
        XML
        ng_rec = Nokogiri::XML.parse(rec_str)
        expect(indexer.map_record(ng_rec)).to include 'range' => [1999, 2000]
      end
    end
    context 'when single date provided' do
      it 'range is a single value Array' do
        rec_str = <<-XML
        <?xml version="1.0" encoding="utf-8" ?>
        <!DOCTYPE metadata SYSTEM "http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd">
        <metadata>
          <idinfo>
            <timeperd>
              <timeinfo>
                <sngdate>
                  <caldate>1725</caldate>
                </sngdate>
              </timeinfo>
            </timeperd>
          </idinfo>
        </metadata>
        XML
        ng_rec = Nokogiri::XML.parse(rec_str)
        expect(indexer.map_record(ng_rec)).to include 'range' => [1725]
      end
      it 'year in future results in no value' do
        rec_str = <<-XML
        <?xml version="1.0" encoding="utf-8" ?>
        <!DOCTYPE metadata SYSTEM "http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd">
        <metadata>
          <idinfo>
            <timeperd>
              <timeinfo>
                <sngdate>
                  <caldate>2725</caldate>
                </sngdate>
              </timeinfo>
            </timeperd>
          </idinfo>
        </metadata>
        XML
        ng_rec = Nokogiri::XML.parse(rec_str)
        expect(indexer.map_record(ng_rec)).not_to include 'range'
      end
    end
  end

  describe '#hijri_range' do
    before do
      indexer.instance_eval do
        to_field 'int_array', accumulate { |record, *_| record[:value] }, hijri_range
      end
    end

    it 'receives a range of integers' do
      expect(indexer.map_record(value: [2010, 2011, 2012])).to include 'int_array' => [1431, 1432, 1433, 1434]
    end

    it 'receives a single value' do
      expect(indexer.map_record(value: [623])).to include 'int_array' => [1, 2]
    end

    it 'is not provided a value' do
      expect(indexer.map_record(value: [])).to be_empty
    end

    it 'receives a bc value' do
      expect(indexer.map_record(value: [-10, -9, -8])).to include 'int_array' => [-651, -650, -649, -648]
    end
  end

  describe '#marc_date_range' do
    {
      # 008[06-14] => expected result
      'e20070615' => [2007],
      'i17811799' => (1781..1799).to_a,
      'k08uu09uu' => (800..999).to_a,
      'm19721975' => (1972..1975).to_a,
      'q159u159u' => (1590..1599).to_a,
      'r19701916' => [1916],
      'r19uu1922' => [1922],
      's1554    ' => [1554],
      's15uu    ' => (1500..1599).to_a,
      's193u    ' => (1930..1939).to_a,
      's08uu    ' => (800..899).to_a
    }.each_pair do |raw_val, expected|
      it "#{raw_val} from 008[06-14] gets correct result" do
        indexer.to_field('range', raw_val_lambda, indexer.marc_date_range)
        expect(indexer.map_record(raw: raw_val)).to include 'range' => expected
      end
    end

    [
      't19821949', # date range not valid
      'a19992000' # unrecognized date_type 'a'
    ].each do |raw_val|
      it "#{raw_val} from 008[06-14] has no value as expected" do
        indexer.to_field('range', raw_val_lambda, indexer.marc_date_range)
        expect(indexer.map_record(raw: raw_val)).to eq({})
      end
    end
  end

  describe '#met_date_range' do
    before do
      indexer.instance_eval do
        to_field 'range', met_date_range
      end
    end

    context 'when objectBeginDate and objectEndDate populated' do
      it 'both dates and range are valid' do
        expect(indexer.map_record('objectBeginDate' => '-2', 'objectEndDate' => '1')).to include 'range' => [-2, -1, 0, 1]
        expect(indexer.map_record('objectBeginDate' => '-11', 'objectEndDate' => '1')).to include 'range' => (-11..1).to_a
        expect(indexer.map_record('objectBeginDate' => '-100', 'objectEndDate' => '-99')).to include 'range' => [-100, -99]
        expect(indexer.map_record('objectBeginDate' => '-1540', 'objectEndDate' => '-1538')).to include 'range' => (-1540..-1538).to_a
        expect(indexer.map_record('objectBeginDate' => '0', 'objectEndDate' => '99')).to include 'range' => (0..99).to_a
        expect(indexer.map_record('objectBeginDate' => '1', 'objectEndDate' => '10')).to include 'range' => (1..10).to_a
        expect(indexer.map_record('objectBeginDate' => '300', 'objectEndDate' => '319')).to include 'range' => (300..319).to_a
        expect(indexer.map_record('objectBeginDate' => '666', 'objectEndDate' => '666')).to include 'range' => [666]
      end

      it 'invalid range raises exception' do
        expect { indexer.map_record('objectBeginDate' => '1539', 'objectEndDate' => '1292') }.to raise_error(StandardError, 'unable to create year array from 1539, 1292')
      end
    end

    it 'when one date is empty, range is a single year' do
      expect(indexer.map_record('objectBeginDate' => '300')).to include 'range' => [300]
      expect(indexer.map_record('objectEndDate' => '666')).to include 'range' => [666]
    end

    it 'when both dates are empty, no error is raised' do
      expect(indexer.map_record({})).to eq({})
    end

    it 'date strings with text and numbers are interpreted as 0' do
      expect(indexer.map_record('date_made_early' => 'not999', 'date_made_late' => 'year of 1939')).to eq({})
    end
  end

  describe '#penn_museum_date_range' do
    before do
      indexer.instance_eval do
        to_field 'range', penn_museum_date_range
      end
    end

    context 'when date_made_early and date_made_late populated' do
      it 'both dates and range are valid' do
        expect(indexer.map_record('date_made_early' => '-2', 'date_made_late' => '1')).to include 'range' => [-2, -1, 0, 1]
        expect(indexer.map_record('date_made_early' => '-11', 'date_made_late' => '1')).to include 'range' => (-11..1).to_a
        expect(indexer.map_record('date_made_early' => '-100', 'date_made_late' => '-99')).to include 'range' => [-100, -99]
        expect(indexer.map_record('date_made_early' => '-1540', 'date_made_late' => '-1538')).to include 'range' => (-1540..-1538).to_a
        expect(indexer.map_record('date_made_early' => '0', 'date_made_late' => '99')).to include 'range' => (0..99).to_a
        expect(indexer.map_record('date_made_early' => '1', 'date_made_late' => '10')).to include 'range' => (1..10).to_a
        expect(indexer.map_record('date_made_early' => '300', 'date_made_late' => '319')).to include 'range' => (300..319).to_a
        expect(indexer.map_record('date_made_early' => '666', 'date_made_late' => '666')).to include 'range' => [666]
      end

      it 'invalid range raises exception' do
        expect { indexer.map_record('date_made_early' => '1539', 'date_made_late' => '1292') }.to raise_error(StandardError, 'unable to create year array from 1539, 1292')
      end

      it 'future date year raises exception' do
        expect { indexer.map_record('date_made_early' => '1539', 'date_made_late' => '2050') }.to raise_error(StandardError, 'unable to create year array from 1539, 2050')
      end
    end

    it 'when one date is empty, range is a single year' do
      expect(indexer.map_record('date_made_early' => '300')).to include 'range' => [300]
      expect(indexer.map_record('date_made_late' => '666')).to include 'range' => [666]
    end

    it 'when both dates are empty, no error is raised' do
      expect(indexer.map_record({})).to eq({})
    end

    it 'date strings with no numbers are interpreted as missing' do
      expect(indexer.map_record('date_made_early' => 'not_a_number', 'date_made_late' => 'me_too')).to eq({})
    end

    it 'date strings with text and numbers are interpreted as 0' do
      expect(indexer.map_record('date_made_early' => 'not999', 'date_made_late' => 'year of 1939')).to include 'range' => [0]
    end
  end

  describe '#year_array' do
    context 'valid input' do
      [
        ['1993', '1995', [1993, 1994, 1995]],
        ['0', '0001', [0, 1]],
        ['-0003', '0000', [-3, -2, -1, 0]],
        ['-1', '1', [-1, 0, 1]],
        ['15', '15', [15]],
        ['-100', '-99', [-100, -99]],
        ['98', '101', [98, 99, 100, 101]]
      ].each do |example|
        first_year = example[0]
        last_year = example[1]
        expected = example[2]
        it "(#{first_year} to #{last_year})" do
          expect(Macros::DateParsing.year_array(first_year, last_year)).to eq expected
        end
      end
    end
    context 'invalid input' do
      [
        ['1993', '1992'],
        ['-99', '-100'],
        ['12345', '12345']
      ].each do |example|
        first_year = example[0]
        last_year = example[1]
        it "(#{first_year} to #{last_year})" do
          exp_msg_regex = /unable to create year array from #{first_year}, #{last_year}/
          expect { Macros::DateParsing.year_array(first_year, last_year) }.to raise_error(StandardError, exp_msg_regex)
        end
      end
    end
  end
end
