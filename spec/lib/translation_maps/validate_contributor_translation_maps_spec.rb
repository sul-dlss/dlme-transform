# frozen_string_literal: true

require 'yaml'

# expect that all the values listed in contributor_map_filename are translatable using the
# mapping config specified by lang_map_name
RSpec.shared_examples 'a valid translation map' do |lang_map_name, contributor_map_filename|
  YAML.load_file(contributor_map_filename).each do |_key, values|
    Array(values).each do |literal_value| # ensure values is an array (since values can be a string OR an array of strings)
      context "with a value from #{contributor_map_filename}" do
        let(:translation) do
          indexer = Traject::Indexer.new
          indexer.configure do
            to_field 'cho_to_field', literal(literal_value), translation_map(lang_map_name)
          end
          indexer.map_record(nil)['cho_to_field']
        end

        it "translates #{literal_value} using #{lang_map_name}" do
          expect(translation).not_to be_nil
        end
      end
    end
  end
end

RSpec.describe 'contributor translation maps are valid' do # rubocop:disable RSpec/DescribeClass this tests config consistency, not a class
  # TODO: un-skip once we have the translations that will make it pass. see https://github.com/sul-dlss/dlme-transform/issues/738
  # it_behaves_like 'a valid translation map', 'temporal_ar_from_en', 'lib/translation_maps/temporal_from_contributor.yaml'

  it_behaves_like 'a valid translation map', 'spatial_ar_from_en', 'lib/translation_maps/spatial_from_contributor.yaml'

  # TODO: un-skip once we have the translations that will make it pass. see https://github.com/sul-dlss/dlme-transform/issues/740
  it_behaves_like 'a valid translation map', 'has_type_ar_from_en', 'lib/translation_maps/has_type_from_fr.yaml'
  # it_behaves_like 'a valid translation map', 'edm_type_from_has_type', 'lib/translation_maps/has_type_from_fr.yaml'

  # TODO: un-skip once we have the translations that will make it pass. see https://github.com/sul-dlss/dlme-transform/issues/741
  it_behaves_like 'a valid translation map', 'has_type_ar_from_en', 'lib/translation_maps/has_type_from_lausanne.yaml'
  # it_behaves_like 'a valid translation map', 'edm_type_from_has_type', 'lib/translation_maps/has_type_from_lausanne.yaml'

  # TODO: un-skip once we have the translations that will make it pass. see https://github.com/sul-dlss/dlme-transform/issues/742
  it_behaves_like 'a valid translation map', 'has_type_ar_from_en', 'lib/translation_maps/has_type_from_tr.yaml'
  # it_behaves_like 'a valid translation map', 'edm_type_from_has_type', 'lib/translation_maps/has_type_from_tr.yaml'

  it_behaves_like 'a valid translation map', 'edm_type_ar_from_en', 'lib/translation_maps/edm_type_from_has_type.yaml'

  # TODO: un-skip once we have the translations that will make it pass. see https://github.com/sul-dlss/dlme-transform/issues/743
  # it_behaves_like 'a valid translation map', 'getty_aat_material_ar_from_en', 'lib/translation_maps/getty_aat_material_from_contributor.yaml'

  # TODO: un-skip once we have the translations that will make it pass. see https://github.com/sul-dlss/dlme-transform/issues/744
  it_behaves_like 'a valid translation map', 'has_type_ar_from_en', 'lib/translation_maps/has_type_from_contributor.yaml'
  # it_behaves_like 'a valid translation map', 'edm_type_from_has_type', 'lib/translation_maps/has_type_from_contributor.yaml'
end
