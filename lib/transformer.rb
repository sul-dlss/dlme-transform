# frozen_string_literal: true

require 'traject'
module Dlme
  # Determines mapping of data filepaths to config files.
  class TransformMapper
    attr_reader :mapping_config, :base_data_dir, :data_dir

    # Initialize a new instance of the mapper
    #
    # @param mapping [hash] mapping of Traject config file to transformation attributes
    # @param base_data_dir [String] base filepath for data directories
    # @param data_dir [String] relative filepath for the data directory to be transformed
    def initialize(mapping_config:, base_data_dir:, data_dir:)
      @mapping_config = mapping_config
      @base_data_dir = base_data_dir
      @data_dir = data_dir
    end

    # Performs the mapping, returning a hash of data filepaths to config filenames
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def map
      mapping = {}
      mapping_config.each do |config|
        config['paths'].each do |path|
          next unless data_dir.start_with?(path) || path.start_with?(data_dir) || data_dir.empty?

          data_files = if File.file?(abs_data_dir)
                         [abs_data_dir]
                       else
                         # Glob on whichever is longer
                         glob_path = path.length > data_dir.length ? path : data_dir
                         Dir.glob("#{abs_dir(glob_path)}/**/*#{config.fetch('extension', '.xml')}")
                       end
          data_files.each do |filepath|
            # First matching config wins
            mapping[filepath] = config unless mapping.key?(filepath)
          end
        end
      end
      mapping
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    private

    def abs_data_dir
      abs_dir(data_dir)
    end

    def abs_dir(dir)
      "#{@base_data_dir}/#{dir}"
    end
  end

  # Generic Traject transformer
  class Transformer
    attr_reader :input_filepath, :config_filepaths, :addl_settings

    # Initialize a new instance of the transformer
    #
    # @param input_filepath [String] filepath of input file
    # @param config_filepath [Array] filepaths of the config file
    # @param settings [hash] additional settings
    def initialize(input_filepath:, config_filepaths:, settings: {})
      @input_filepath = input_filepath
      @config_filepaths = config_filepaths
      @addl_settings = settings
    end

    # Transform a stream into a new representation, using Traject
    def transform
      transformer.process(File.open(input_filepath, 'r'))
    rescue RuntimeError => e
      warn "[ERROR] #{e.message}"
      exit(1)
    end

    private

    def transformer
      this = self
      @transformer ||= Traject::Indexer.new.tap do |indexer|
        config_filepaths.each { |config_filepath| indexer.load_config_file(config_filepath) }
        indexer.settings do
          provide 'command_line.filename', this.input_filepath
          this.addl_settings.each { |key, value| provide key, value }
        end
      end
    end
  end
end
