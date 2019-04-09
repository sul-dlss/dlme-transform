# frozen_string_literal: true

require 'traject_plus'

module Macros
  # Macros for working with CONTENTdm data
  module ContentDm
    NS = {
      oai: 'http://www.openarchives.org/OAI/2.0/',
      dc: 'http://purl.org/dc/elements/1.1/',
      oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    }.freeze
    private_constant :NS

    ID_XPATH = '/oai:record/oai:metadata/oai_dc:dc/dc:identifier[last()]'
    private_constant :ID_XPATH

    # Grab a CONTENTdm object URI from a record
    # @return [String] the CONTENTdm object URI
    def select_cdm_identifier(record, _context)
      uri = record.xpath(ID_XPATH, NS).map(&:text).reject(&:blank?)
      return uri.first if uri.any?
    end

    # Get a value for `agg_preview` from a record
    # @return [Proc] a proc that traject can call for each record
    def extract_cdm_preview(responsive: true)
      lambda do |rec, acc, ctx|
        acc << cdm_thumbnail(select_cdm_identifier(rec, ctx), responsive: responsive)
      end
    end

    # Construct a thumbnail URI from a CONTENTdm object URI. This method
    # assumes that it receives a URI as returned from CONTENTdm's OAI-PMH
    # provider. Adapted from https://github.com/dpla/ingestion/blob/master/lib/akamod/contentdm_identify_object.py
    # @param uri [String] the CONTENTdm object URI
    # @param responsive [true, false] generate links to the CONTENTdm 7 and
    #    later responsive UI
    # @return [String, nil] the URI to the thumbnail or nil
    def cdm_thumbnail(uri, responsive: true)
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
