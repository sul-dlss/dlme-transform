# frozen_string_literal: true

require 'macros/eastview'

RSpec.describe Macros::Eastview do
  def new_macro_aware_indexer
    Traject::Indexer.new.tap do |idx|
      idx.instance_eval do
        extend Macros::Eastview
        extend TrajectPlus::Macros
      end
    end
  end

  describe '#generate_eastview_issue_id' do
    let(:indexer) { new_macro_aware_indexer }

    before do
      indexer.instance_eval do
        to_field 'eastview_id', generate_eastview_issue_id('base_id_field', 'url_field')
      end
    end

    context 'when URL is valid and contains "d" parameter' do
      # rubocop:disable RSpec/ExampleLength
      it 'generates the correct unique ID' do
        record = {
          'base_id_field' => 'ocn123456',
          'url_field' => 'http://eastview.com/docs?a=param1&d=unique_part_123abc&b=param2'
        }
        result = indexer.map_record(record)
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
        expect(result['eastview_id']).to eq(['ocn7890_unique_part-with_special_chars__'])
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when URL field is missing or empty' do
      it 'skips the record if URL field is missing' do
        record = {
          'base_id_field' => 'ocn_missing_url'
        }
        result = indexer.map_record(record)
        expect(result).to be_nil
      end

      # rubocop:disable RSpec/ExampleLength
      it 'skips the record if URL field is empty' do
        record = {
          'base_id_field' => 'ocn_empty_url',
          'url_field' => ''
        }
        result = indexer.map_record(record)
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

  describe '#eastview_issue_date' do
    let(:indexer) { new_macro_aware_indexer }

    before do
      indexer.instance_eval do
        to_field 'issue_date', eastview_issue_date
      end
    end

    context 'when issue-text is present and contains a date' do
      it 'extracts and formats the date from YYYY-MM-DD' do
        record = { 'issue-text' => ['Some text with a date 2023-01-01 and more.'] }
        result = indexer.map_record(record)
        expect(result['issue_date']).to eq(['2023-01-01'])
      end

      it 'extracts and formats the date from YYYY.MM.DD' do
        record = { 'issue-text' => ['Published on 2024.07.15.'] }
        result = indexer.map_record(record)
        expect(result['issue_date']).to eq(['2024-07-15'])
      end

      it 'extracts multiple dates if present' do
        record = { 'issue-text' => ['Date 2022.05.10 and another 2023-12-25.'] }
        result = indexer.map_record(record)
        expect(result['issue_date']).to contain_exactly('2022-05-10', '2023-12-25')
      end
    end

    context 'when issue-text is present but contains no date' do
      it 'does not map any field' do
        record = { 'issue-text' => ['No date here.'] }
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
    end

    context 'when issue-text is an empty array' do
      it 'does not map any field' do
        record = { 'issue-text' => [] }
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
    end

    context 'when issue-text is missing from the record' do
      it 'does not map any field' do
        record = { 'some_other_field' => 'value' }
        result = indexer.map_record(record)
        expect(result).to eq({})
      end
    end
  end
end
