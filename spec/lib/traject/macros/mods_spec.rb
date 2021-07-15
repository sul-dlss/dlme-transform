# frozen_string_literal: true

require 'macros/mods'
require 'macros/language_extraction'

RSpec.describe Macros::Mods do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::Mods
        extend Macros::LanguageExtraction
      end
    end
  end

  describe '#extract_name' do
    let(:record) do
      <<~XML
        <mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:mods="http://www.loc.gov/mods/v3"
          xmlns:sets="http://hul.harvard.edu/ois/xml/ns/sets"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          xmlns:marc="http://www.loc.gov/MARC21/slim"
          xmlns:HarvardDRS="http://hul.harvard.edu/ois/xml/ns/HarvardDRS"
          xmlns:librarycloud="http://hul.harvard.edu/ois/xml/ns/librarycloud" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd" version="3.6">
          <mods:name>
            <mods:namePart>Doe, John</mods:namePart>
            <mods:role>
              <mods:roleTerm type="text">copyist.</mods:roleTerm>
            </mods:role>
          </mods:name>
        </mods>
      XML
    end
    let(:ng_rec) { Nokogiri::XML.parse(record) }

    context 'when contributor role matches the search' do
      before do
        indexer.instance_eval do
          to_field 'cho_contributor', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', role: 'copyist.') # , strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
        end
      end

      it 'returns values with a mapped role' do
        expect(indexer.map_record(ng_rec)).to eq({ 'cho_contributor' => ['Doe, John (Copyist)'] })
      end
    end

    context 'when contributor role does not match the search' do
      before do
        indexer.instance_eval do
          to_field 'cho_contributor', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', role: 'scribe.') # , strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
        end
      end

      it 'returns an empty hash' do
        expect(indexer.map_record(ng_rec)).to eq({})
      end
    end

    context 'when role is excluded from the search' do
      before do
        indexer.instance_eval do
          to_field 'cho_contributor', extract_name('//*/mods:name[1][mods:role/mods:roleTerm/', exclude: true) # , strip, arabic_script_lang_or_default('und-Arab', 'und-Latn')
        end
      end

      it 'returns values without role included' do
        expect(indexer.map_record(ng_rec)).to eq({ 'cho_contributor' => ['Doe, John'] })
      end
    end
  end
end
