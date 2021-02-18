require 'macros/date_parsing'
require 'macros/string_helper'
# frozen_string_literal: true

module Macros
  # Macros for extracting OAI values from Nokogiri documents
  module HarvardSCW
    NS = {
      cdwalite: 'http://www.getty.edu/research/conducting_research/standards/cdwa/cdwalite',
      HarvardDRS: 'http://hul.harvard.edu/ois/xml/ns/HarvardDRS',
      mods: 'http://www.loc.gov/mods/v3'
    }.freeze
    private_constant :NS

    include Macros::DateParsing
    include Macros::StringHelper
    include Traject::Macros::NokogiriMacros

    # Extracts values for the given xpath which is prefixed with HarvardDRS wrappers
    # @example
    #   extract_harvard('HarvardDRS:drsObjectId') => lambda { ... }
    # @param [String] xpath the xpath query expression
    # @return [Proc] a proc that traject can call for each record
    def extract_harvard(xpath)
      extract_xpath(xpath.to_s, ns: NS)
    end

    SCW_ACCEPTABLE_TYPES = [
      'drawing', 'drawings', 'drawings (visual works)', 'sketches', 'illuminated manuscript', 'illuminated manuscripts',
      'manuscript', 'manuscripts', 'miniatures (paintings)', 'painted manuscripts', 'painting', 'paintings',
      'painting/drawing', 'paintings (visual works)', 'single page painting/drawing', 'watercolors',
      'watercolors (paintings)', 'illustrations (layout features)', 'painted cloth', 'rubbings', 'combs', 'ivories',
      'lacquerware', 'blades (tool and equipment components)', 'bronze', 'bronzes', 'metalwork', 'utilitarian objects',
      'trays', 'sculpture', 'ceramic', 'ceramic tile', 'ceramic tiles', 'ceramics', 'ceramics (objects)', 'flask', 'flasks',
      'flasks (bottles)', 'fritware', 'glass', 'glasswork', 'pottery', 'pottery (object genre)', 'jade (rock)', 'stonework',
      'stone carving', 'stone and marble', 'dyed fabrics', 'hangings (textiles)', 'kalamkari', 'shawls', 'textile',
      'textiles', 'woodwork', 'wood carvings', 'wall paintings', 'enamel', 'gold', 'copper', 'steel', 'opaque watercolor',
      'marble', 'copper (metal)', 'wool', 'leather', 'bowls', 'photograph', 'jewelry', 'jewelry, personal ornaments',
      'necklaces', 'costume ornaments', 'earrings', 'plaques (flat objects)', 'gemstone', 'amulets', 'book covers',
      'illustrated book', 'carvings', 'architecture', 'portraits', 'album', 'album leaf', 'albums', 'gourd',
      'perfume bottles', 'ink', 'nephrite', 'copper engravings (visual works)', 'calligraphy', 'chandeliers', 'still image'
    ].freeze

    # Determines the cho_has_type value for Harvard SCW records. There is not
    # a single reliable source to map for this field so four fields are extracted,
    # appended to an array in a particular order, and the first match in the array
    # is passed to a translation map. It is a fragile process and not 100% accurate
    # but it seems mostly accurate and some data is better than none.
    # @example
    #   scw_has_type => lambda { ... }
    # @return [Proc] a proc that traject can call for each record
    def scw_has_type
      lambda do |record, accumulator|
        type_values = []
        genres = record.xpath('/*/mods:genre', NS)
        genres.each do |val|
          type_values << val&.content&.strip&.downcase
        end
        types = record.xpath('/*/mods:typeOfResource', NS)
        types.each do |val|
          type_values << val&.content&.strip&.downcase
        end
        subjects = record.xpath('/*/mods:subject/mods:topic', NS)
        subjects.each do |val|
          type_values << val&.content&.strip&.downcase
        end
        materials_techniques = record.xpath('/*/mods:extension/cdwalite:indexingMaterialsTechSet/'\
                                            'cdwalite:termMaterialsTech', NS)
        materials_techniques.each do |val|
          type_values << val&.content&.strip&.downcase
        end
        raw_type = SCW_ACCEPTABLE_TYPES.find { |i| type_values.include? i }
        accumulator << raw_type if raw_type
      end
    end
  end
end
