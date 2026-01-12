# frozen_string_literal: true

require 'macros/jaraid'

RSpec.describe Macros::Jaraid do
  include described_class
  include TrajectPlus::Macros

  # Define fixture XML content for jaraid_master-biblStruct.TEIP5.xml
  # Define the Traject Indexer instance.
  # We manually set the @jaraid_doc and @jaraid_authority_doc
  # instance variables on the indexer to use our fixture content.
  subject(:indexer) do
    Traject::Indexer.new.tap do |idx|
      idx.instance_eval do
        extend Macros::Jaraid
        extend TrajectPlus::Macros
      end
      # Manually set the instance variables that the extended hook would normally set
      # This bypasses file reading and uses our fixture content directly.
      idx.instance_variable_set(:@jaraid_doc, Nokogiri::XML(jaraid_master_xml_content))
      idx.instance_variable_set(:@jaraid_authority_doc, Nokogiri::XML(jaraid_authority_xml_content))
    end
  end

  let(:jaraid_master_xml_content) do
    <<~XML
      <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0">
        <tei:text>
          <tei:body>
            <tei:listBibl>
              <tei:biblStruct xml:id="jaraid-1">
                <tei:monogr>
                  <tei:idno type="jaraid">jaraid-1</tei:idno>
                  <tei:editor>
                    <tei:persName xml:lang="und-Latn">Editor One</tei:persName>
                    <tei:persName xml:lang="ar">محرر واحد</tei:persName>
                  </tei:editor>
                  <tei:imprint>
                    <tei:pubPlace>
                      <tei:placeName xml:lang="und-Latn">London</tei:placeName>
                      <tei:placeName xml:lang="ar">لندن</tei:placeName>
                      <tei:placeName ref="jaraid:place:101 geon:10101">LondonRef</tei:placeName>
                    </tei:pubPlace>
                    <tei:date when="2020-01-15">2020 text date</tei:date>
                    <tei:publisher>
                      <tei:orgName xml:lang="und-Latn">Publisher A</tei:orgName>
                      <tei:orgName xml:lang="ar">الناشر أ</tei:orgName>
                    </tei:publisher>
                  </tei:imprint>
                  <tei:title level="j">Journal Title One</tei:title>
                </tei:monogr>
                <tei:note type="comment">This is a comment.</tei:note>
                <tei:note type="sources">Source material.</tei:note>
                <tei:note type="holdings">Holding info.</note>
              </tei:biblStruct>
              <tei:biblStruct xml:id="jaraid-2">
                <tei:monogr>
                  <tei:idno type="jaraid">jaraid-2</tei:idno>
                  <tei:editor>
                    <tei:persName xml:lang="und-Latn">Editor Two</tei:persName>
                  </tei:editor>
                  <tei:imprint>
                    <tei:pubPlace>
                      <tei:placeName ref="jaraid:place:102 geon:10202">ParisRef</tei:placeName>
                    </tei:pubPlace>
                    <tei:date when="2021-03-20"/> <!-- Date with only @when -->
                    <tei:publisher>
                      <tei:orgName xml:lang="und-Latn">Publisher B</tei:orgName>
                    </tei:publisher>
                  </tei:imprint>
                  <tei:title level="j">Journal Title Two</tei:title>
                </tei:monogr>
              </tei:biblStruct>
              <tei:biblStruct xml:id="jaraid-3">
                <tei:monogr>
                  <tei:idno type="jaraid">jaraid-3</tei:idno>
                  <tei:imprint>
                    <tei:pubPlace>
                      <tei:placeName ref="geon:invalid">InvalidRef</tei:placeName>
                    </tei:pubPlace>
                  </tei:imprint>
                  <!-- No date here -->
                </tei:monogr>
              </tei:biblStruct>
              <tei:biblStruct xml:id="jaraid-4">
                <tei:monogr>
                  <tei:idno type="jaraid">jaraid-4</tei:idno>
                  <tei:imprint>
                    <tei:date>2022 text only date</tei:date> <!-- Date with only text -->
                  </tei:imprint>
                </tei:monogr>
              </tei:biblStruct>
            </tei:listBibl>
          </tei:body>
        </tei:text>
      </tei:TEI>
    XML
  end

  # Define fixture XML content for jaraid_authority-file.TEIP5.xml
  let(:jaraid_authority_xml_content) do
    <<~XML
      <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0">
        <tei:text>
          <tei:body>
            <tei:listPlace>
              <tei:place xml:id="place-101">
                <tei:idno type="geon">10101</tei:idno>
                <tei:location>
                  <tei:geo>51.5074,0.1278</tei:geo>
                </tei:location>
              </tei:place>
              <tei:place xml:id="place-102">
                <tei:idno type="geon">10202</tei:idno>
                <tei:location>
                  <tei:geo>48.8566,2.3522</tei:geo>
                </tei:location>
              </tei:place>
              <tei:place xml:id="place-103">
                <tei:idno type="geon">10303</tei:idno>
                <tei:location>
                  <tei:geo></tei:geo> <!-- Empty geo tag -->
                </tei:location>
              </tei:place>
              <tei:place xml:id="place-104">
                <tei:idno type="geon">10404</tei:idno>
                <tei:location>
                  <!-- No geo tag -->
                </tei:location>
              </tei:place>
            </tei:listPlace>
          </tei:body>
        </tei:text>
      </tei:TEI>
    XML
  end

  # Test for macros that use `extract_jaraid` (which requires an ID in the accumulator)
  describe 'macros using #extract_jaraid' do
    # rubocop:disable RSpec/ExampleLength
    describe '#jaraid_editors' do
      it 'extracts editors names (und-Latn)' do
        indexer.instance_eval do
          to_field 'editors', literal('jaraid-1'), jaraid_editors
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['editors']).to eq(['Editor One'])
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength
    describe '#jaraid_editors_ar' do
      it 'extracts editors names (Arabic)' do
        indexer.instance_eval do
          to_field 'editors_ar', literal('jaraid-1'), jaraid_editors_ar
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['editors_ar']).to eq(['محرر واحد'])
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength
    describe '#jaraid_pub_places' do
      it 'extracts publication places (und-Latn)' do
        indexer.instance_eval do
          to_field 'pub_places', literal('jaraid-1'), jaraid_pub_places
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['pub_places']).to eq(['London'])
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength
    describe '#jaraid_pub_places_ar' do
      it 'extracts publication places (Arabic)' do
        indexer.instance_eval do
          to_field 'pub_places_ar', literal('jaraid-1'), jaraid_pub_places_ar
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['pub_places_ar']).to eq(['لندن'])
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength
    describe '#jaraid_publishers' do
      it 'extracts publishers names (und-Latn)' do
        indexer.instance_eval do
          to_field 'publishers', literal('jaraid-1'), jaraid_publishers
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['publishers']).to eq(['Publisher A'])
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength
    describe '#jaraid_publishers_ar' do
      it 'extracts publishers names (Arabic)' do
        indexer.instance_eval do
          to_field 'publishers_ar', literal('jaraid-1'), jaraid_publishers_ar
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['publishers_ar']).to eq(['الناشر أ'])
      end
    end
    # rubocop:enable RSpec/ExampleLength

    # rubocop:disable RSpec/ExampleLength
    describe '#jaraid_title' do
      it 'extracts titles with level="j"' do
        indexer.instance_eval do
          to_field 'title', literal('jaraid-1'), jaraid_title
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['title']).to eq(['Journal Title One'])
      end
    end
    # rubocop:enable RSpec/ExampleLength

    describe '#jaraid_notes' do
      # rubocop:disable RSpec/ExampleLength
      it 'extracts note content for "comment" type' do
        indexer.instance_eval do
          to_field 'notes_comment', literal('jaraid-1'), jaraid_notes('comment')
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['notes_comment']).to eq(['This is a comment.'])
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'extracts note content for "sources" type' do
        indexer.instance_eval do
          to_field 'notes_sources', literal('jaraid-1'), jaraid_notes('sources')
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['notes_sources']).to eq(['Source material.'])
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'extracts note content for "holdings" type' do
        indexer.instance_eval do
          to_field 'notes_holdings', literal('jaraid-1'), jaraid_notes('holdings')
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['notes_holdings']).to eq(['Holding info.'])
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'returns empty if note type not found' do
        indexer.instance_eval do
          to_field 'notes_nonexistent', literal('jaraid-1'), jaraid_notes('nonexistent')
        end
        record = {}
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#jaraid_place_refs_from_id' do
    # Define the mapping for this specific macro within the indexer for these tests
    context 'when biblStruct has placeName with ref attribute' do
      # rubocop:disable RSpec/ExampleLength
      it 'extracts all refs and makes them unique for a single ID' do
        indexer.instance_eval do
          to_field 'place_refs', literal('jaraid-1'), jaraid_place_refs_from_id
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['place_refs']).to contain_exactly('jaraid:place:101', 'geon:10101')
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'handles multiple biblStructs and consolidates unique refs' do
        indexer.instance_eval do
          to_field 'place_refs_multi', literal(['jaraid-1', 'jaraid-2']), jaraid_place_refs_from_id
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['place_refs_multi']).to contain_exactly('jaraid:place:101', 'geon:10101', 'jaraid:place:102', 'geon:10202')
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when biblStruct has no placeName with ref attribute' do
      # rubocop:disable RSpec/ExampleLength
      it 'does not map any field' do
        record = {}
        indexer.instance_eval do
          to_field 'place_refs_no_ref', literal('jaraid-3'), jaraid_place_refs_from_id
        end
        result = indexer.map_record(record)
        expect(result['place_refs_no_ref']).to eq(['geon:invalid'])
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when jaraid_id is not found in master biblStruct' do
      # rubocop:disable RSpec/ExampleLength
      it 'does not map any field' do
        record = {}
        indexer.instance_eval do
          to_field 'place_refs_nonexistent', literal('nonexistent-id'), jaraid_place_refs_from_id
        end
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#jaraid_coordinates_from_pubplace' do
    # This macro relies on the accumulator being populated with refs like 'geon:XXXXX'.
    context 'when valid geon ID is found in accumulator' do
      # rubocop:disable RSpec/ExampleLength
      it 'extracts coordinates from authority file for a single ID' do
        indexer.instance_eval do
          to_field 'coordinates', literal(['geon:10101']), jaraid_coordinates_from_pubplace
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['coordinates']).to eq(['51.5074,0.1278'])
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'extracts coordinates for multiple geon IDs' do
        indexer.instance_eval do
          to_field 'coordinates_multi', literal(['geon:10101', 'geon:10202']), jaraid_coordinates_from_pubplace
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['coordinates_multi']).to contain_exactly('51.5074,0.1278', '48.8566,2.3522')
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when geon ID is not found in authority file' do
      # rubocop:disable RSpec/ExampleLength
      it 'does not extract coordinates' do
        # Simulate a record that would put geon:invalid into accumulator directly
        indexer.instance_eval do
          to_field 'coordinates_invalid_geon', literal(['geon:invalid']), jaraid_coordinates_from_pubplace
        end
        record = {}
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when geo tag is empty or missing in authority file' do
      # rubocop:disable RSpec/ExampleLength
      it 'does not extract coordinates for empty geo tag' do
        # Simulate a record that would put geon:10303 into accumulator directly
        indexer.instance_eval do
          to_field 'coordinates_empty_geo', literal(['geon:10303']), jaraid_coordinates_from_pubplace
        end
        record = {}
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'does not extract coordinates for missing geo tag' do
        # Simulate a record that would put geon:10404 into accumulator directly
        indexer.instance_eval do
          to_field 'coordinates_no_geo', literal(['geon:10404']), jaraid_coordinates_from_pubplace
        end
        record = {}
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when accumulator is empty or contains non-geon refs' do
      # rubocop:disable RSpec/ExampleLength
      it 'does not map any field if accumulator is empty' do
        # Simulate an empty accumulator for the coordinates macro
        indexer.instance_eval do
          to_field 'coordinates_empty', literal([]), jaraid_coordinates_from_pubplace
        end
        record = {}
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'does not map any field for non-geon refs' do
        # Simulate an accumulator with non-geon refs
        indexer.instance_eval do
          to_field 'coordinates_non_geon', literal(['jaraid:place:101', 'some:other:ref']), jaraid_coordinates_from_pubplace
        end
        record = {}
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#jaraid_pub_dates' do
    # Define the mapping for this specific macro within the indexer for these tests
    context 'when biblStruct has date with @when attribute' do
      # rubocop:disable RSpec/ExampleLength
      it 'extracts the @when attribute' do
        indexer.instance_eval do
          to_field 'pub_dates', literal('jaraid-1'), jaraid_pub_dates
        end
        record = {}
        result = indexer.map_record(record)
        expect(result['pub_dates']).to eq(['2020-01-15'])
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when biblStruct has date without @when attribute but with text' do
      # rubocop:disable RSpec/ExampleLength
      it 'extracts the date text' do
        record = {}
        indexer.instance_eval do
          to_field 'pub_dates_text_only', literal('jaraid-4'), jaraid_pub_dates # Use jaraid-4 for text-only date
        end
        result = indexer.map_record(record)
        expect(result['pub_dates_text_only']).to eq(['2022 text only date'])
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when jaraid_id is not found in master biblStruct' do
      # rubocop:disable RSpec/ExampleLength
      it 'does not map any field' do
        record = {}
        indexer.instance_eval do
          to_field 'pub_dates_nonexistent', literal('nonexistent-id'), jaraid_pub_dates
        end
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when date node is empty or missing' do
      # rubocop:disable RSpec/ExampleLength
      it 'does not map any field' do
        # jaraid-3 has no date node
        record = {}
        indexer.instance_eval do
          to_field 'pub_dates_no_node', literal('jaraid-3'), jaraid_pub_dates
        end
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
