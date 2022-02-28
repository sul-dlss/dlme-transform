# frozen_string_literal: true

require 'yaml'

# expect that all the values in preceding_translation_maps appear as keys in
# next_translation_map; used to ensure values get translated when chaining
# translation maps together
RSpec.shared_examples 'a valid translation map chain' do |next_translation_map, preceding_translation_maps|
  keys_in_next_translation_map = []
  YAML.load_file(next_translation_map).each do |key, _values|
    keys_in_next_translation_map << key.downcase
  end
  preceding_translation_maps.each do |preceding_translation_map|
    YAML.load_file(preceding_translation_map).each do |_key, values|
      Array(values).each do |literal_value|
        context "with a value from #{preceding_translation_map}" do
          it "translates #{literal_value} using #{next_translation_map}" do
            expect(keys_in_next_translation_map).to include(literal_value.downcase)
          end
        end
      end
    end
  end
end

RSpec.describe 'contributor translation maps are valid' do # rubocop:disable RSpec/DescribeClass this tests config consistency, not a class
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/type_hierarchy_ar_from_en.yaml', ['lib/translation_maps/type_hierarchy_from_contributor.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/agg_collection_ar_from_en.yaml', ['lib/translation_maps/agg_collection_from_provider.yaml', 'lib/translation_maps/agg_collection_from_provider_id.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/edm_type_ar_from_en.yaml', ['lib/translation_maps/edm_type_from_has_type.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/edm_type_from_has_type.yaml', ['lib/translation_maps/has_type_from_fr.yaml', 'lib/translation_maps/has_type_from_lausanne.yaml', 'lib/translation_maps/has_type_from_tr.yaml', 'lib/translation_maps/has_type_from_contributor.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/getty_aat_material_ar_from_en.yaml', ['lib/translation_maps/getty_aat_material_from_contributor.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/has_type_ar_from_en.yaml', ['lib/translation_maps/has_type_from_fr.yaml', 'lib/translation_maps/has_type_from_lausanne.yaml', 'lib/translation_maps/has_type_from_tr.yaml', 'lib/translation_maps/has_type_from_contributor.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/lang_ar_from_en.yaml', ['lib/translation_maps/lang_from_downcased.yaml', 'lib/translation_maps/lang_from_iso_639-1.yaml', 'lib/translation_maps/lang_from_turkish.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/spatial_ar_from_en.yaml', ['lib/translation_maps/spatial_from_contributor.yaml']
  it_behaves_like 'a valid translation map chain', 'lib/translation_maps/temporal_ar_from_en.yaml', ['lib/translation_maps/temporal_from_contributor.yaml']
end
