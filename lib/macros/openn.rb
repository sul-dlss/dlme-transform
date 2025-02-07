# frozen_string_literal: true

require 'traject_plus'

module Macros
  # DLME helpers for traject mappings
  module Openn
    extend TrajectPlus::Macros::JSON

    def extract_agg_shown_at(harvest_url_key)
      lambda do |rec, acc|
        collection_id = JsonPath.on(rec, harvest_url_key)[0].split('/Data/')[-1].split('/')[0]
        record_id = JsonPath.on(rec, harvest_url_key)[0].split('/Data/')[-1].split('/')[1]
        agg_shown_at_url = "https://openn.library.upenn.edu/Data/#{collection_id}/html/#{record_id}.html"
        acc.replace([agg_shown_at_url])
      end
    end

    def extract_preview_url(harvest_url_key, preview_key)
      lambda do |rec, acc|
        collection_record_id = JsonPath.on(rec, harvest_url_key)[0].split('/Data/')[-1].split('/data/')[0]
        preview = JsonPath.on(rec, preview_key)[0]
        preview_url = "https://openn.library.upenn.edu/Data/#{collection_record_id}/data/#{preview}"
        acc.replace([preview_url])
      end
    end
  end
end
