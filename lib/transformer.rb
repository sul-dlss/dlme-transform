# frozen_string_literal: true

module Dlme
  # Generic Traject transformer
  class Transformer
    attr_reader :input_filepath, :config_filepaths, :addl_settings, :debug_writer

    # Initialize a new instance of the transformer
    #
    # @param input_filepath [String] filepath of input file
    # @param config_filepath [Array] filepaths of the config file
    # @param settings [hash] additional settings
    def initialize(input_filepath:, config_filepaths:, settings: {}, debug_writer: nil)
      @input_filepath = input_filepath
      @config_filepaths = config_filepaths
      @addl_settings = settings
      @debug_writer = debug_writer
    end

    # Transform a stream into a new representation, using Traject, and returns the number of transformed records.
    def transform
      transformer.process(File.open(input_filepath, 'r'))
    end

    private

    def transformer
      this = self
      @transformer ||= Traject::Indexer.new.tap do |indexer|
        config_filepaths.each { |config_filepath| indexer.load_config_file(config_filepath) }
        indexer.load_config_file('lib/record_counter_config.rb')
        indexer.settings do
          provide 'command_line.filename', this.input_filepath
          store 'writer_class_name', 'Traject::DebugWriter' if this.debug_writer
          this.addl_settings.each { |key, value| provide key, value }
        end
      end
    end
  end
end
