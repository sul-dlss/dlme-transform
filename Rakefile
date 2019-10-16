# frozen_string_literal: true

# Allow requiring contents of `lib/`
$LOAD_PATH.unshift(File.join(File.expand_path(__dir__), 'lib'))

require 'cli' # loads dependency tree needed for tasks below

desc 'Mapping-related tasks'
namespace :mappings do
  desc "Sort metadata mappings by path (writes to #{Settings.defaults.mapping_file})"
  task :sort do
    json_mappings = File.read(Settings.defaults.mapping_file)
    mappings = JSON.parse(json_mappings)
    mappings.sort! { |mapping_x, mapping_y| mapping_x['paths'].first <=> mapping_y['paths'].first }
    File.open(Settings.defaults.mapping_file, 'w') do |file|
      file.puts JSON.pretty_generate(mappings)
    end
  end
end
