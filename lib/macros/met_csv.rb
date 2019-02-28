# frozen_string_literal: true

require 'met_thumbnail_fetcher'

module Macros
  # Macros for extracting values from CSV rows
  module MetCsv
    DISPLAY_NAME = 'Artist Display Name'
    private_constant :DISPLAY_NAME
    SUFFIX = 'Artist Suffix'
    private_constant :SUFFIX
    BEGIN_DATE = 'Artist Begin Date'
    private_constant :BEGIN_DATE
    END_DATE = 'Artist End Date'
    private_constant :END_DATE
    OBJECT_BEGIN_DATE = 'Object Begin Date'
    private_constant :OBJECT_BEGIN_DATE
    OBJECT_END_DATE = 'Object End Date'
    private_constant :OBJECT_END_DATE
    ROLE = 'Artist Role'
    private_constant :ROLE
    BIO = 'Artist Display Bio'
    private_constant :BIO
    CLASSIFICATION = 'Classification'
    private_constant :CLASSIFICATION
    PUBLIC_DOMAIN = 'Is Public Domain'
    private_constant :PUBLIC_DOMAIN
    DEPARTMENT = 'Department'
    private_constant :DEPARTMENT
    REPOSITORY = 'Repository'
    private_constant :REPOSITORY

    # Retrieves the thumbnail url from the Met's API. This must be called after
    # the ++id++ is set in the ++output_hash++
    # @return [Proc] a proc that traject can call for each record
    def met_thumbnail
      lambda do |_record, accumulator, context|
        ident = context.output_hash['id'].first.sub(/^met_/, '')
        thumbnail = MetThumbnailFetcher.fetch(ident)
        accumulator << transform_values(context, 'wr_id' => literal(thumbnail)) if thumbnail
      end
    end

    # Builds the creator for the row.
    # @return [Proc] a proc that traject can call for each record
    def generate_creator
      lambda do |row, accumulator, _context|
        accumulator << [row[DISPLAY_NAME], row[SUFFIX], artist_role_bio(row)].select(&:present?).join(', ').presence
      end
    end

    # Builds the object date for the row.
    # @return [Proc] a proc that traject can call for each record
    def generate_object_date
      lambda do |row, accumulator, _context|
        object_date = row[OBJECT_BEGIN_DATE] unless row[OBJECT_BEGIN_DATE].to_s.empty?
        object_date = "#{object_date} - #{row[OBJECT_END_DATE]}" unless row[OBJECT_END_DATE].to_s.empty?
        accumulator << object_date
      end
    end

    # Builds the EDM type for the row.
    # @return [Proc] a proc that traject can call for each record
    def edm_type
      lambda do |row, accumulator, _context|
        accumulator << 'Image' if row[CLASSIFICATION].present?
      end
    end

    # Sets either "Public Domain" or "Not Public Domain" for the row.
    # @return [Proc] a proc that traject can call for each record
    def public_domain
      lambda do |row, accumulator, _context|
        accumulator << 'Public Domain' if row[PUBLIC_DOMAIN] == 'True'
        accumulator << 'Not Public Domain' if row[PUBLIC_DOMAIN] == 'False'
      end
    end

    # Sets the data provider value from the department and repository columns.
    # @note This overrides the DLME macro of the same name
    # @see DLME#data_provider
    # @return [Proc] a proc that traject can call for each record
    def data_provider
      lambda do |row, accumulator, _context|
        accumulator << [row[DEPARTMENT], row[REPOSITORY]].select(&:present?).join(', ').presence
      end
    end

    private

    def artist_date_range(row)
      [row[BEGIN_DATE], row[END_DATE]].select(&:present?).join(' - ')
    end

    def artist_role_bio(row)
      role = [row[ROLE], row[BIO]].select(&:present?).join(' ; ')
      artist_info = artist_date_range(row)
      artist_info += " (#{role})" if role.present?
      artist_info
    end
  end
end
