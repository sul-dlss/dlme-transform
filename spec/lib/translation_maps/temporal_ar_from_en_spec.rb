# frozen_string_literal: true

require 'yaml'

RSpec.describe 'temporal_ar_from_en translation map' do # rubocop:disable RSpec/DescribeClass this tests config consistency, not a class
  let(:translation) do
    indexer = Traject::Indexer.new
    this = self
    indexer.configure do
      to_field 'cho_temporal', literal(this.key), translation_map('temporal_ar_from_en')
    end
    indexer.map_record(nil)['cho_temporal']
  end

  YAML.load_file('lib/translation_maps/temporal_from_contributor.yaml').each do |_key, values|
    values = [values] if values.is_a? String # required since the values can strings OR arrays of strings
    values.each do |value|
      context 'with a value from temporal_from_contributor' do
        let(:key) { value }

        # TODO: un-skip once we have the translations that will make it pass. see https://github.com/sul-dlss/dlme-transform/issues/738
        xit "translates #{value} to Arabic" do
          expect(translation).not_to be_nil
        end
      end
    end
  end
end
