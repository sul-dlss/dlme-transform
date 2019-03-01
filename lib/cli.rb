# frozen_string_literal: true

require 'json'
require 'thor'
require 'transformer'
require 'record_counter'
require 'date'
require 'config_finder'

module Dlme
  module CLI
    # Transform subcommand
    class Transform < Thor
      option :mapping_file,
             default: 'config/metadata_mapping.json',
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

      option :summary_filepath,
             banner: 'SUMMARY_FILEPATH',
             desc: 'Filepath containing summary of transformation.',
             aliases: '-s'

      option :debug_writer,
             type: :boolean,
             banner: 'DEBUG_WRITER',
             desc: 'Use the debug writer.',
             aliases: '-w'

      desc 'transform', 'Perform a transform'
      def transform
        @start = Time.now
        transform_all
        write_summary
      rescue StandardError => e
        warn "[ERROR] #{e.message}"
        write_summary(error: e.message)
        raise e unless e < RuntimeError

        exit(1)
      end

      default_task :transform

      private

      # @raise RuntimeError if no files are found
      def transform_all
        configs.each do |data_filepath, config|
          Transformer.new(
            input_filepath: data_filepath,
            config_filepaths: config['trajects'].map { |traject| "#{options.fetch(:traject_dir)}/#{traject}" },
            settings: config.fetch('settings', {}),
            debug_writer: options[:debug_writer]
          ).transform
        end
      end

      # @raise RuntimeError if no files are found
      def configs
        ConfigFinder.for(base_data_dir: options.fetch(:base_data_dir),
                         data_dir: options.fetch(:data_dir),
                         mapping_file: options.fetch(:mapping_file))
      end

      def write_summary(error: nil)
        return unless options.key?(:summary_filepath)

        summary = build_summary(error: error)
        File.open(options.fetch(:summary_filepath), 'w') do |f|
          f.puts(JSON.generate(summary))
        end
      end

      def build_summary(error: nil)
        result = {
          'success' => error.nil?,
          'records' => RecordCounter.instance.count,
          'data_path' => options.fetch(:data_dir),
          'timestamp' => DateTime.now.iso8601,
          'duration' => (Time.now - @start).to_i
        }
        result['error'] = error unless error.nil?
        result
      end
    end
  end
end
