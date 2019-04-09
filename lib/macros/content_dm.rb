# frozen_string_literal: true

module Macros
  # Macros for working with CONTENTdm data
  module ContentDm
    # Construct a thumbnail URI from a CONTENTdm object URI. This method
    # assumes that it receives a URI as returned from CONTENTdm's OAI-PMH
    # provider. Adapted from https://github.com/dpla/ingestion/blob/master/lib/akamod/contentdm_identify_object.py
    # @param uri [String] the CONTENTdm object URI
    # @param responsive [true, false] generate links to the CONTENTdm 7 and
    #    later responsive UI
    def thumbnail(uri, responsive: true)
      return uri.gsub('cdm/ref', 'digital/api/singleitem') + '/thumbnail' if uri.include?('cdm/ref') && responsive
      return uri.gsub('cdm/ref', 'utils/getthumbnail') if uri.include?('cdm/ref')
      # if `digital` is in the URI it's already served in the responsive UI
      return cdm_responsive_thumb(uri) if uri.include?('digital/collection')
      return cdm_old_style_thumb(uri) if uri.include?('u?')
    end

    def cdm_responsive_thumb(uri)
      uri.gsub('digital/collection', 'digital/api/singleitem/collection') + '/thumbnail'
    end

    def cdm_old_style_thumb(uri)
      # handle old-style CDM URIs; assume that responsive UI is not available
      u = URI(uri)
      collection, id = u.query.split(',')
      u.path = '/cgi-bin/thumbnail.exe'
      u.query = "CISOROOT=#{collection}&CISOPTR=#{id}"
      u.to_s
    end
  end
end
