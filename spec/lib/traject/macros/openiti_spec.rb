# frozen_string_literal: true

require 'macros/openiti'
require 'minitest/autorun'
require 'webmock/minitest'

class OpenITIMacroTest < Minitest::Test
  include Macros::OpenITI
  def setup
    # Mock the HTTParty call
    WebMock.stub_request(:get, 'https://example.com')
           .to_return(body: { 'obj_descr_en' => 'This is the description for a record (English) written by %<author_lat>s' }.to_yaml)
  end

  def test_object_description_en
    # Sample record data
    record = { 'author_ar' => 'Author Name (Arabic)', 'author_lat' => 'Author Name (English)',
               'text_url' => 'https://example.com/text', 'one2all_data_url' => 'https://example.com/data',
               'one2all_stats_url' => 'https://example.com/stats', 'one2all_vis_url' => 'https://example.com/vis',
               'uncorrected_ocr_ar' => '...', 'uncorrected_ocr_en' => '...' }

    # Call the macro and get the description
    description = Macros::OpenITI.object_description('lat').call(record, [])

    # Assert the expected description
    expect(description.first).to eq('This is the description for a record (English) written by Author Name (English)')
  end
end
