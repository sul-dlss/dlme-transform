# frozen_string_literal: true

require 'yaml'

# expect that all the values listed in translation_map_filename appear only once;
# use to make sure two different incoming values don't get translated to the same
# outcoming value.
RSpec.shared_examples 'a set' do |translation_map_filename|
  all_values = []
  YAML.load_file(translation_map_filename).each do |_key, values|
    all_values << values
  end
  it 'has only unique values' do
    expect(all_values).to match_array(all_values.uniq)
  end
end

RSpec.describe 'translation map (values) are a set' do # rubocop:disable RSpec/DescribeClass this tests config consistency, not a class
  it_behaves_like 'a set', 'lib/translation_maps/agg_collection_from_provider_id.yaml'
  it_behaves_like 'a set', 'lib/translation_maps/dlme_collection_ar_from_en.yaml'
end
