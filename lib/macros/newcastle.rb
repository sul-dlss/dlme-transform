# frozen_string_literal: true

module Macros
  # Macros specific to Newcastle University metadata
  module Newcastle
    # Extracts id values, converts them to an integer, increments by 2, and build the thumbnail url
    def newcastle_thumbnail
      lambda do |record, accumulator|
        return if record['.iiif_manifest'].nil?

        result = record['.iiif_manifest']
        thumnail_id_integer = result.gsub('/manifest.json', '').gsub('https://cdm21051.contentdm.oclc.org/iiif/info/p21051coll46/', '').to_i + 2
        thumnail_url = "https://cdm21051.contentdm.oclc.org/iiif/2/p21051coll46:#{thumnail_id_integer}/full/!400,400/0/default.jpg"
        accumulator.replace([thumnail_url]) if thumnail_url
      end
    end
  end
end
