# frozen_string_literal: true

require 'json'
require 'thor'
require 'transformer'

module Dlme
  module CLI
    # Transform subcommand
    class Transform < Thor
      option :mapping_file,
             default: 'metadata_mapping.json',
             banner: 'MAPPING_FILEPATH',
             desc: 'Filepath of JSON file that maps directories to config files.',
             aliases: '-m'

      option :base_data_dir,
             default: 'data',
             banner: 'BASE_DATA_DIR',
             desc: 'Parent directory containing the data to be transformed.',
             aliases: '-b'

      option :data_dir,
             default: '',
             banner: 'DATA_DIR',
             desc: 'Directory containing the data to be transformed, relative to the BASE_DATA_DIR. Descendent ' \
                   'directories will be recursively transformed. If a file, only that file will be transformed.',
             aliases: '-d'

      option :traject_dir,
             default: 'config',
             banner: 'TRAJECT_DIR',
             desc: 'Directory containing the Traject configs.',
             aliases: '-t'

      desc 'transform', 'Perform a transform'
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def transform
        data_filepath_mapping = TransformMapper.new(
          mapping_config: mapping,
          base_data_dir: options.fetch(:base_data_dir),
          data_dir: options.fetch(:data_dir)
        ).map
        data_filepath_mapping.each do |data_filepath, config|
          Transformer.new(
            input_filepath: data_filepath,
            config_filepaths: config['trajects'].map { |traject| "#{options.fetch(:traject_dir)}/#{traject}" },
            settings: config.fetch('settings', {})
          ).transform
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      default_task :transform

      private

      def mapping
        @mapping ||= JSON.parse(File.read(options.fetch(:mapping_file)))
      end
    end
  end
end
