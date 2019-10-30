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

  describe '#parse_range' do
    before do
      indexer.instance_eval do
        to_field 'int_array', accumulate { |record, *_| record[:value] }, parse_range
      end
    end

    it 'parseable values' do
      expect(indexer.map_record(value: '2019')).to include 'int_array' => [2019]
      expect(indexer.map_record(value: '12/25/00')).to include 'int_array' => [2000]
      expect(indexer.map_record(value: '5-1-25')).to include 'int_array' => [1925]
      expect(indexer.map_record(value: '-914')).to include 'int_array' => [-914]
      expect(indexer.map_record(value: '1666 B.C.')).to include 'int_array' => [-1666]
      expect(indexer.map_record(value: '2017-2019')).to include 'int_array' => [2017, 2018, 2019]
      expect(indexer.map_record(value: 'between 1830 and 1899?')).to include 'int_array' => (1830..1899).to_a
      expect(indexer.map_record(value: '196u')).to include 'int_array' => (1960..1969).to_a
      expect(indexer.map_record(value: '17--')).to include 'int_array' => (1700..1799).to_a
      expect(indexer.map_record(value: '1602 or 1603')).to include 'int_array' => [1602, 1603]
      expect(indexer.map_record(value: 'between 300 and 150 B.C')).to include 'int_array' => (-300..-150).to_a
      expect(indexer.map_record(value: '18th century CE')).to include 'int_array' => (1700..1799).to_a
      expect(indexer.map_record(value: 'ca. 10th–9th century B.C.')).to include 'int_array' => (-1099..-900).to_a
      expect(indexer.map_record(value: 'Sun, 12 Nov 2017 14:08:12 +0000')).to include 'int_array' => [2017] # aims
    end

    it 'when missing date' do
      expect(indexer.map_record({})).to eq({})
    end
  end

  mixed_hijri_gregorian =
    [ # raw, hijri part, gregorian part
      # openn
      ['A.H. 986 (1578)', '986', '1578'],
      ['A.H. 899 (1493-1494)', '899', '1493-1494'],
      ['A.H. 901-904 (1496-1499)', '901-904', '1496-1499'],
      ['A.H. 1240 (1824)', '1240', '1824'],
      ['A.H. 1258? (1842)', '1258?', '1842'],
      ['A.H. 1224, 1259 (1809, 1843)', '1224, 1259', '1809, 1843'],
      ['A.H. 1123?-1225 (1711?-1810)', '1123?-1225', '1711?-1810'],
      ['ca. 1670 (A.H. 1081)', '1081', 'ca. 1670'],
      ['1269 A.H. (1852)', '1269', '1852'],
      # cambridge islamic
      ['628 A.H. / 1231 C.E.', '628', '1231 C.E.'],
      ['974 AH / 1566 CE', '974', '1566 CE'],
      # sakip-sabanci Kitapvehat
      ['887 H (1482 M)', '887', '1482 M'],
      ['1269, 1272, 1273 H (1853, 1855, 1856 M)', '1269, 1272, 1273', '1853, 1855, 1856 M'],
      ['1194 H (1780 M)', '1194', '1780 M'],
      ['1101 H (1689-1690 M)', '1101', '1689-1690 M'],
      ['1240, 1248 H (1825, 1832 M)', '1240, 1248', '1825, 1832 M'],
      ['1080 H (1669-1670 M)', '1080', '1669-1670 M'],
      ['1076 H (1665-1666)', '1076', '1665-1666'],
    ]

  describe '#extract_gregorian' do
    before do
      indexer.instance_eval do
        to_field 'gregorian', accumulate { |record, *_| record[:value] }, extract_gregorian
      end
    end
    mixed_hijri_gregorian.each do |raw, exp_hijri, exp_gregorian|
      it "#{raw} results in string containing '#{exp_gregorian}' and not '#{exp_hijri}'" do
        result = indexer.map_record(value: raw)['gregorian'].first
        expect(result).to match(Regexp.escape(exp_gregorian))
        expect(result).not_to match(Regexp.escape(exp_hijri))
      end
    end

    it 'no hijri present - assumes gregorian' do
      expect(indexer.map_record(value: '1894.')).to include 'gregorian' => ['1894.']
      expect(indexer.map_record(value: '1890-')).to include 'gregorian' => ['1890-']
      expect(indexer.map_record(value: '1886-1887')).to include 'gregorian' => ['1886-1887']
      # harvard ihp -  Gregorian is within square brackets - handled in diff macro
      expect(indexer.map_record(value: '1322 [1904]')).to include 'gregorian' => ['1322 [1904]']
      expect(indexer.map_record(value: '1317 [1899 or 1900]')).to include 'gregorian' => ['1317 [1899 or 1900]']
      expect(indexer.map_record(value: '1288 [1871-72]')).to include 'gregorian' => ['1288 [1871-72]']
      expect(indexer.map_record(value: '1254 [1838 or 39]')).to include 'gregorian' => ['1254 [1838 or 39]']
    end

    it 'only hijri present - no parseable valid gregorian' do
      result = indexer.map_record(value: '1225 H')['gregorian'].first
      expect(result).not_to match(Regexp.escape('1225'))
    end

    it 'missing value' do
      expect(indexer.map_record({})).to eq({})
    end
  end

  describe '#extract_or_compute_hijri_range' do
    before do
      indexer.instance_eval do
        to_field 'hijri_range', accumulate { |record, *_| record[:value] }, extract_or_compute_hijri_range
      end
    end

    context 'when hijri dates range provided' do
      mixed_hijri_gregorian.each do |raw, exp_hijri, _exp_gregorian|
        it "#{raw} results in parse_range for '#{exp_hijri}'" do
          expect(ParseDate).to receive(:parse_range).with(exp_hijri).and_call_original
          expect(indexer.map_record(value: raw)).to include 'hijri_range'
        end
      end
    end
    context 'when no hijri provided' do
      it 'hijri range is computed from gregorian range' do
        expect(Macros::DateParsing).to receive(:to_hijri).exactly(4).times.and_call_original
        expect(indexer.map_record(value: '1894')).to include 'hijri_range' => [1311, 1312]
        expect(indexer.map_record(value: '1886-1887')).to include 'hijri_range' => [1303, 1304, 1305]
      end
    end

    it 'missing value' do
      expect(indexer.map_record({})).to eq({})
    end
  end

  describe '#cambridge_gregorian_range' do
    let(:record) do
      <<-XML
        <tei:teiHeader xmlns:tei='http://www.tei-c.org/ns/1.0'>
          <tei:fileDesc>
            <tei:sourceDesc>
              <tei:msDesc>
                <tei:history>
                  <tei:origin>
                    #{orig_date_el}
                  </tei:origin>
                </tei:history>
              </tei:msDesc>
            </tei:sourceDesc>
          </tei:fileDesc>
        </tei:teiHeader>
      XML
    end
    let(:ng_rec) { Nokogiri::XML.parse(record) }

    before do
      indexer.instance_eval do
        to_field 'range', cambridge_gregorian_range
      end
    end

    context "when 'notBefore' and 'notAfter' attributes provided" do
      let(:orig_date_el) { '<tei:origDate calendar="Gregorian" notBefore="1700" notAfter="1750">First half of eighteenth century</tei:origDate>' }

      it 'gets range from attribute values' do
        expect(indexer.map_record(ng_rec)).to include 'range' => (1700..1750).to_a
      end

      context 'when attrib values are negative' do
        let(:orig_date_el) { '<tei:origDate calendar="Gregorian" notBefore="-0200" notAfter="-0100">Middle of second century BCE</tei:origDate>' }
        it 'gets range from attribute values' do
          expect(indexer.map_record(ng_rec)).to include 'range' => (-200..-100).to_a
        end
      end

      context 'when attrib values are yyyy-mm-dd' do
        let(:orig_date_el) { '<tei:origDate calendar="Hijri-qamari" from="1000-01-01" to="1610-12-31">Not after 1019/1610 C.E.</tei:origDate>' }

        it 'gets range from attribute values' do
          expect(indexer.map_record(ng_rec)).to include 'range' => (1000..1610).to_a
        end
      end

      context 'when attrib values are empty' do
        let(:orig_date_el) { '<tei:origDate calendar="Gregorian" notBefore="" notAfter="">1230—1239 CE</tei:origDate>' }

        it 'gets range from parsing element value' do
          expect(indexer.map_record(ng_rec)).to include 'range' => (1230..1239).to_a
        end
      end
    end

    context "when 'from' and 'to' attributes provided (Islamic collection)" do
      let(:orig_date_el) { '<tei:origDate calendar="Gregorian" from="0800" to="0877" instant="false">Before 264 AH</tei:origDate>' }
      it 'gets range from atttribute values' do
        expect(indexer.map_record(ng_rec)).to include 'range' => (800..877).to_a
      end

      context 'when attrib values are yyyy-mm-dd' do
        let(:orig_date_el) { '<tei:origDate calendar="Hijri-qamari" from="1000-01-01" to="1610-12-31">Not after 1019/1610 C.E.</tei:origDate>' }

        it 'gets range from attribute values' do
          expect(indexer.map_record(ng_rec)).to include 'range' => (1000..1610).to_a
        end
      end
    end

    context "when 'when' attribute provided" do
      let(:orig_date_el) { '<tei:origDate calendar="Gregorian" when="1592" unit="mm">1000 A.H. / 1592 C.E.</tei:origDate>' }
      it 'gets single year range from attribute value' do
        expect(indexer.map_record(ng_rec)).to include 'range' => [1592]
      end

      context 'when attrib values are yyyy-mm-dd' do
        let(:orig_date_el) { '<tei:origDate calendar="Hijri-qamari" when="1231-01-01" instant="false">628 A.H. / 1231 C.E.</tei:origDate>' }
        it 'gets single year range from attribute value' do
          expect(indexer.map_record(ng_rec)).to include 'range' => [1231]
        end
      end
    end

    context 'when no helpful attributes provided' do
      let(:orig_date_el) { '<tei:origDate calendar="Gregorian">4th century A.H / 10th century C.E.</tei:origDate>' }

      it 'gets range from parsing element value' do
        expect(indexer.map_record(ng_rec)).to include 'range' => (900..999).to_a
      end

      context 'when no value available' do
        let(:orig_date_el) { '<tei:origDate calendar="Hijri-qamari">undated</tei:origDate>' }
        it 'the field is absent' do
          expect(indexer.map_record(ng_rec)).not_to include 'range'
        end
      end
    end
  end

  describe '#fgdc_date_range' do
    let(:record) do
      <<-XML
        <!DOCTYPE metadata SYSTEM "http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd">
        <metadata>
          <idinfo>
            <timeperd>
              <timeinfo>
                #{time_info_els}
              </timeinfo>
            </timeperd>
          </idinfo>
        </metadata>
      XML
    end
    let(:ng_rec) { Nokogiri::XML.parse(record) }

    before do
      indexer.instance_eval do
        to_field 'range', fgdc_date_range
      end
    end

    context 'when rngdates element provided' do
      let(:time_info_els) do
        '<rngdates>
          <begdate>19990211</begdate>
          <enddate>20000222</enddate>
        </rngdates>'
      end

      it 'range is from begdate to enddate' do
        expect(indexer.map_record(ng_rec)).to include 'range' => [1999, 2000]
      end
    end

    context 'when single date provided' do
      let(:time_info_els) do
        '<sngdate>
          <caldate>1725</caldate>
        </sngdate>'
      end
      it 'range is a single value Array' do
        expect(indexer.map_record(ng_rec)).to include 'range' => [1725]
      end
    end

    context 'year in future' do
      let(:time_info_els) do
        '<sngdate>
          <caldate>2725</caldate>
        </sngdate>'
      end

      it 'results in no value' do
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
        exp_err_msg = 'unable to create year range array from 1539, 1292'
        expect { indexer.map_record('objectBeginDate' => '1539', 'objectEndDate' => '1292') }.to raise_error(StandardError, exp_err_msg)
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

  describe '#mods_date_range' do
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
        to_field 'range', mods_date_range
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
        let(:date_els) { '<mods:dateCreated encoding="w3cdtf" keyDate="yes" qualifier="inferred">1725</mods:dateCreated>' }
        it 'uses value for range' do
          expect(indexer.map_record(ng_rec)).to include 'range' => [1725]
        end
      end
      # we have no dateCreated elements without point or keyDate attributes
    end

    context 'when dateValid but no dateCreated elements exists' do
      # we have no dateValid elements with point or keyDate attributes
      context 'when no attributes of interest' do
        let(:date_els) { '<mods:dateValid>19th century</mods:dateValid>' }
        it 'uses value for range' do
          expect(indexer.map_record(ng_rec)).to include 'range' => (1800..1899).to_a
        end
      end
      context 'when dateIssued also present' do
        let(:date_els) do
          '<mods:dateIssued encoding="w3cdtf" keyDate="yes">2012</mods:dateIssued>
          <mods:dateValid encoding="w3cdtf">1990</mods:dateValid>'
        end
        it 'uses value from dateValid' do
          expect(indexer.map_record(ng_rec)).to include 'range' => [1990]
        end
      end
    end

    context 'when dateIssued but no dateCreated or dateValid elements' do
      # we have no dateIssued elements with point attributes
      context 'when keyDate attribute but no point attributes' do
        let(:date_els) { '<mods:dateIssued encoding="w3cdtf" keyDate="yes">2013</mods:dateIssued>' }
        it 'uses value for range' do
          expect(indexer.map_record(ng_rec)).to include 'range' => [2013]
        end
      end
      context 'when no attributes of interest' do
        let(:date_els) do
          '<mods:dateIssued>ca. 1720]</mods:dateIssued>
          <mods:dateIssued encoding="marc">1720</mods:dateIssued>'
        end
        it 'uses first value for range' do
          expect(indexer.map_record(ng_rec)).to include 'range' => [1720]
        end
      end
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
        exp_err_msg = 'unable to create year range array from 1539, 1292'
        expect { indexer.map_record('date_made_early' => '1539', 'date_made_late' => '1292') }.to raise_error(StandardError, exp_err_msg)
      end

      it 'future date year raises exception' do
        exp_err_msg = 'unable to create year range array from 1539, 2050'
        expect { indexer.map_record('date_made_early' => '1539', 'date_made_late' => '2050') }.to raise_error(StandardError, exp_err_msg)
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
end
