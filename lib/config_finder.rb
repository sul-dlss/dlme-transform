# frozen_string_literal: true

module Dlme
  # Compiles a list of configs to use for the given filepaths
  class ConfigFinder
    # @raise RuntimeError if no files are found
    def self.for(base_data_dir:, data_dir:, mapping_file:, sample: false)
      new(base_data_dir: base_data_dir,
          data_dir: data_dir,
          mapping_file: mapping_file,
          sample: sample).find
    end

    def initialize(base_data_dir:, data_dir:, mapping_file:, sample:)
      @base_data_dir = base_data_dir
      @data_dir = data_dir
      @mapping_file = mapping_file
      @sample = sample
    end

    # @raise RuntimeError if no files are found
    def find
      paths = build_paths
      return paths unless paths.empty?

      raise "File not found: #{data_dir} in #{base_data_dir}"
    end

    private

    # Performs the mapping, returning a hash of data filepaths to config filenames
    def build_paths
      mapping = {}
      mapping_config.each do |config|
        config['paths'].each do |path|
          next unless data_dir.start_with?(path) || path.start_with?(data_dir) || data_dir.empty?

          data_files(config, path).each do |filepath|
            # First matching config wins
            mapping[filepath] ||= config
          end
        end
      end
      mapping
    end

    def data_files(config, path)
      return [abs_data_dir] if File.file?(abs_data_dir)

      # Glob on whichever is longer
      glob_path = path.length > data_dir.length ? path : data_dir
      files = Dir.glob("#{abs_dir(glob_path)}/**/*#{config.fetch('extension', '.xml')}")
      return files.take(Settings.number_of_configs_to_test) if sample

      files
    end

    def abs_data_dir
      abs_dir(data_dir)
    end

    def abs_dir(dir)
      "#{base_data_dir}/#{dir}"
    end

    def mapping_config
      JSON.parse(File.read(mapping_file))
    end

    attr_reader :base_data_dir, :data_dir, :mapping_file, :sample
  end
end
