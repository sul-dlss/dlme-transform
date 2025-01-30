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

  describe 'extract_person_date_role' do
    # Sample records
    let(:all_fields) { { 'person' => 'John Doe', 'date' => '1880-1923', 'role' => 'author' } }
    let(:no_date) { { 'person' => 'John Doe', 'role' => 'author' } }
    let(:no_role) { { 'person' => 'John Doe', 'date' => '1880-1923' } }
    let(:only_person) { { 'person' => 'John Doe' } }

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
  end
end
