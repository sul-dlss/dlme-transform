# frozen_string_literal: true

module Macros
  # Macros for extracting MODS values from Nokogiri documents
  module Mods
    # Looks up the name from the MODS record
    # @param [String] role (nil) if provided, find the name for the corresponding role
    # @param [String] exclude (nil) if provided, exclude these from the results
    # @return [Proc] a proc that traject can call for each record
    def extract_name(xpath, role: nil, exclude: nil)
      clause = if role
                 Array(role).map { |r| "text() = '#{r}'" }.join(' or ')
               elsif exclude
                 Array(exclude).map { |r| "text() != '#{r}'" }.join(' and ')
               else
                 raise ArgumentError, 'You must provide either role or exclude parameters'
               end
      lambda do |record, accumulator|
        name_parts = []
        name_nodes = record.xpath("#{xpath}#{clause}]/mods:namePart", TrajectPlus::Macros::Mods::NS)
        name_nodes.each do |val|
          name_parts << val&.content&.strip
        end
        role_map = Traject::TranslationMap.new('role_from_contributor')
        role = role_map[role].to_s if role
        accumulator.replace(["#{name_parts.join(', ')} (#{role})"]) if name_parts.present?
      end
    end

    # Gets the identifier from the MODS xml or a default value
    # @return [Proc] a proc that traject can call for each record
    def generate_mods_id
      lambda { |record, accumulator, context|
        identifier = select_identifier(record, context)

        accumulator << identifier_with_prefix(context, identifier) if identifier.present?
      }
    end

    # Grab the identifier from the MODS XML, or if one cannot be found, from the default.
    # @param [Nokogiri::Document] record the MODS xml
    # @param [Traject::Indexer::Context] context
    # @return [String] the identifier
    def select_identifier(record, context)
      if record.xpath('/*/mods:identifier', TrajectPlus::Macros::Mods::NS).map(&:text).reject(&:blank?).any?
        record.xpath('/*/mods:identifier', TrajectPlus::Macros::Mods::NS).map(&:text).reject(&:blank?).first
      else
        default_identifier(context)
      end
    end

    # Grabs the relation URL and title for the given xpath
    # @param [String] xpath an xpath expression for the relation
    # @return [Proc] a proc that traject can call for each record
    # @example
    #    generate_relation('/*/mods:relatedItem[@type="constituent"]')
    def generate_relation(xpath)
      lambda do |record, accumulator|
        url = record.xpath("#{xpath}/mods:location/mods:url", TrajectPlus::Macros::Mods::NS).map(&:text)
        title = record.xpath("#{xpath}/mods:titleInfo/mods:title", TrajectPlus::Macros::Mods::NS).map(&:text)

        if url.present?
          accumulator.concat(url)
        elsif title.present?
          accumulator.concat(title)
        end
      end
    end

    # Looks up the type from the MODS document and normalizes it using the ++lib/translation_maps/types.yaml++ table
    # @return [Proc] a proc that traject can call for each record
    def normalize_mods_type
      extract_mods('/*/mods:typeOfResource', translation_map: 'types')
    end

    # Looks up the language from the MODS document and normalizes it using the
    # ++lib/translation_maps/marc_languages.yaml++ table
    # @return [Proc] a proc that traject can call for each record
    def normalize_mods_language
      mods_lang_label_xp = '/*/mods:language/mods:languageTerm[@authority="iso639-2b"][@type="text"]'
      mods_lang_code_xp = '/*/mods:language/mods:languageTerm[@authority="iso639-2b"][@type="code"]'
      mods_lang_xp = '/*/mods:language/mods:languageTerm'
      first(
        extract_mods(mods_lang_label_xp),
        extract_mods(mods_lang_code_xp),
        # the last one is separate to eventually pass fuzzy matching parameters
        extract_mods(mods_lang_xp)
      )
    end

    # Looks up the script from the MODS document and normalizes it using the ++lib/translation_maps/scripts.yaml++ table
    # @return [Proc] a proc that traject can call for each record
    def normalize_mods_script
      extract_mods('/*/mods:language/mods:scriptTerm', translation_map: ['scripts', { default: '__passthrough__' }])
    end
  end
end
