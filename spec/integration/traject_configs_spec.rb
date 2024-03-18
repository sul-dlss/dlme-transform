# frozen_string_literal: true

RSpec.describe 'integration with Traject configs' do
  let!(:configs) do
    Dlme::ConfigFinder.for(
      base_data_dir: 'spec/fixtures/source_data',
      data_dir: Settings.defaults.data_dir,
      mapping_file: Settings.defaults.mapping_file,
      sample: true
    )
  end

  it 'maps a sampling of configs without errors' do
    expect do
      configs.each do |data_filepath, config|
        Dlme::Transformer.new(
          input_filepath: data_filepath,
          config_filepaths: config['trajects'].map { |traject| "#{Settings.defaults.traject_dir}/#{traject}" },
          settings: config.fetch('settings', {})
        ).transform
      rescue StandardError => e
        raise "error raised mapping #{config['settings']['inst_id']} for #{data_filepath}: #{e.class}: #{e.message}"
      end
    end.not_to raise_error
  end
end
