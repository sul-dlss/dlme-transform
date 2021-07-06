# frozen_string_literal: true

require 'yaml'

RSpec.describe 'edm_type_ar_from_en_spec translation map' do
  let(:translation) do
    indexer = Traject::Indexer.new
    this = self
    indexer.configure do
      to_field 'cho_edm_type', literal(this.key), translation_map('edm_type_ar_from_en')
    end
    indexer.map_record(nil)['cho_edm_type']
  end

  has_type = YAML.load_file('lib/translation_maps/edm_type_from_has_type.yaml')
  has_type.each do |_key, values|
    values = [values] if values.is_a? String # required since the values can strings OR arrays of strings
    values.each do |value|
      context 'with a value from edm_type_from_has_type' do
        let(:key) { value }

        it "translates #{value} to Arabic" do
          expect(translation).not_to be_nil
        end
      end
    end
  end
end
