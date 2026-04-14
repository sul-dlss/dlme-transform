# frozen_string_literal: true

require 'macros/field_extraction'

RSpec.describe Macros::FieldExtraction do
  subject(:indexer) do
    Traject::Indexer.new.tap do |indexer|
      indexer.instance_eval do
        extend Macros::FieldExtraction # rubocop:disable RSpec/DescribedClass
        extend TrajectPlus::Macros
      end
    end
  end

  describe 'extract_json_from_context' do
    before do
      indexer.instance_eval do
        to_field 'extracted_json', extract_json_from_context('json_path')
      end
    end

    it 'extracts the value and replaces the accumulator' do
      record = { 'json_path' => { 'nested' => 'value' } }
      expect(indexer.map_record(record)).to eq('extracted_json' => [{ 'nested' => 'value' }])
    end

    it 'does nothing if the path is missing or nil' do
      record = { 'other_path' => 'value' }
      expect(indexer.map_record(record)).to eq({})
    end
  end

  describe 'extract_person_date_role' do
    # Sample records
    let(:all_fields) { { 'person' => 'John Doe', 'date' => '1880-1923', 'role' => 'author' } }
    let(:no_date) { { 'person' => 'John Doe', 'role' => 'author' } }
    let(:no_role) { { 'person' => 'John Doe', 'date' => '1880-1923' } }
    let(:only_person) { { 'person' => 'John Doe' } }
    let(:date_with_comma) { { 'person' => 'John Doe', 'date' => 'Jan 1, 1923', 'role' => 'author' } }

    before do
      indexer.instance_eval do
        to_field 'cho_creator', extract_person_date_role('person', 'date', 'role')
      end
    end

    it 'has all fields' do
      expect(indexer.map_record(all_fields)).to eq('cho_creator' => ['Author: John Doe 1880-1923'])
    end

    it 'has no date' do
      expect(indexer.map_record(no_date)).to eq('cho_creator' => ['Author: John Doe'])
    end

    it 'has no role' do
      expect(indexer.map_record(no_role)).to eq('cho_creator' => ['John Doe 1880-1923'])
    end

    it 'has only person' do
      expect(indexer.map_record(only_person)).to eq('cho_creator' => ['John Doe'])
    end

    it 'removes commas from the date field' do
      expect(indexer.map_record(date_with_comma)).to eq('cho_creator' => ['Author: John Doe Jan 1 1923'])
    end

    it 'ignores empty strings' do
      record = { 'person' => 'John Doe', 'date' => '', 'role' => '' }
      expect(indexer.map_record(record)).to eq('cho_creator' => ['John Doe'])
    end
  end

  describe 'extract_with_fallback' do
    before do
      indexer.instance_eval do
        to_field 'fallback_result', extract_with_fallback([
          'primary_field',
          ['fixed_field', 2, 4], # slice starting at index 2, length 4
          'backup_field'
        ])
      end
    end

    it 'uses the first available field' do
      record = { 'primary_field' => 'Primary Data', 'backup_field' => 'Backup Data' }
      expect(indexer.map_record(record)).to eq('fallback_result' => ['Primary Data'])
    end

    it 'skips empty strings and moves to the next field' do
      record = { 'primary_field' => '', 'backup_field' => 'Backup Data' }
      expect(indexer.map_record(record)).to eq('fallback_result' => ['Backup Data'])
    end

    it 'uses the backup field if primary and fixed fields are missing' do
      record = { 'backup_field' => 'Backup Data' }
      expect(indexer.map_record(record)).to eq('fallback_result' => ['Backup Data'])
    end

    it 'returns nothing if no fields match' do
      record = { 'unrelated_field' => 'Data' }
      expect(indexer.map_record(record)).to eq({})
    end

    context 'with fixed-field slices' do
      it 'extracts the correct slice from a string' do
        record = { 'fixed_field' => '01abcd23' } # index 2, length 4 should be 'abcd'
        expect(indexer.map_record(record)).to eq('fallback_result' => ['abcd'])
      end

      it 'extracts the correct slice from the first element of an array' do
        record = { 'fixed_field' => ['01abcd23', 'other_value'] }
        expect(indexer.map_record(record)).to eq('fallback_result' => ['abcd'])
      end

      it 'strips whitespace from the extracted slice' do
        record = { 'fixed_field' => '01ab  23' } # 'ab  ' should become 'ab'
        expect(indexer.map_record(record)).to eq('fallback_result' => ['ab'])
      end

      it 'skips the fixed field if the string is too short' do
        record = { 'fixed_field' => '01abc', 'backup_field' => 'Backup Data' } # Length is 5, needs to be at least 6 (start 2 + len 4)
        expect(indexer.map_record(record)).to eq('fallback_result' => ['Backup Data'])
      end
    end
  end
end
