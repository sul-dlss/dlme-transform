# frozen_string_literal: true

require 'macros/eastview'

RSpec.describe Macros::Eastview do
  include described_class

  subject(:indexer) do
    Traject::Indexer.new.tap do |idx|
      idx.instance_eval do
        # rubocop:disable RSpec/DescribedClass
        extend Macros::Eastview
        # rubocop:enable RSpec/DescribedClass
        extend TrajectPlus::Macros
      end
    end
  end

  # Before each test, define the Traject mapping.
  before do
    indexer.to_field 'eastview_id', generate_eastview_issue_id('base_id_field', 'url_field')
  end

  describe '#generate_eastview_issue_id' do
    context 'when URL is valid and contains "d" parameter' do
      # rubocop:disable RSpec/ExampleLength
      it 'generates the correct unique ID' do
        record = {
          'base_id_field' => 'ocn123456',
          'url_field' => 'http://eastview.com/docs?a=param1&d=unique_part_123abc&b=param2'
        }
        result = indexer.map_record(record)
        # Expect the 'eastview_id' field to contain the generated ID.
        expect(result['eastview_id']).to eq(['ocn123456_unique_part_123abc'])
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'generates the correct unique ID with special characters in "d" parameter' do
        record = {
          'base_id_field' => 'ocn7890',
          'url_field' => 'http://eastview.com/docs?d=unique/part-with_special_chars!@#$'
        }
        result = indexer.map_record(record)
        # The gsub(/[^a-zA-Z0-9-]/, '_') should replace non-alphanumeric/hyphen with underscore
        expect(result['eastview_id']).to eq(['ocn7890_unique_part-with_special_chars__'])
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when URL field is missing or empty' do
      it 'skips the record if URL field is missing' do
        record = { # Define record directly in the it block
          'base_id_field' => 'ocn_missing_url'
          # 'url_field' is intentionally missing from the record
        }
        result = indexer.map_record(record) # Call map_record directly
        # When context.skip! is called, map_record returns nil for that record.
        expect(result).to be_nil
      end

      # rubocop:disable RSpec/ExampleLength
      it 'skips the record if URL field is empty' do
        record = {
          'base_id_field' => 'ocn_empty_url',
          'url_field' => ''
        }
        result = indexer.map_record(record) # Call map_record directly
        expect(result).to be_nil
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when URL does not contain "d" parameter' do
      # rubocop:disable RSpec/ExampleLength
      it 'skips the record if "d" parameter is missing' do
        record = {
          'base_id_field' => 'ocn_no_d_param',
          'url_field' => 'http://eastview.com/docs?a=param1&b=param2'
        }
        result = indexer.map_record(record)
        expect(result).to be_nil
      end
      # rubocop:enable RSpec/ExampleLength

      # rubocop:disable RSpec/ExampleLength
      it 'skips the record if "d" parameter is empty' do
        record = {
          'base_id_field' => 'ocn_empty_d_param',
          'url_field' => 'http://eastview.com/docs?a=param1&d=&b=param2'
        }
        result = indexer.map_record(record)
        expect(result).to be_nil
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when URL is malformed' do
      # rubocop:disable RSpec/ExampleLength
      it 'skips the record if URL is malformed' do
        record = {
          'base_id_field' => 'ocn_malformed_url',
          'url_field' => 'http://%invalid_url' # Malformed URL
        }
        result = indexer.map_record(record)
        expect(result).to be_nil
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
