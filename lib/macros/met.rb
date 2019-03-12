# frozen_string_literal: true

module Macros
  # Macros for extracting values from JSON docs
  module Met
    DISPLAY_NAME = 'artistDisplayName'
    private_constant :DISPLAY_NAME
    SUFFIX = 'artistSuffix'
    private_constant :SUFFIX
    BEGIN_DATE = 'artistBeginDate'
    private_constant :BEGIN_DATE
    END_DATE = 'artistEndDate'
    private_constant :END_DATE
    OBJECT_BEGIN_DATE = 'objectBeginDate'
    private_constant :OBJECT_BEGIN_DATE
    OBJECT_END_DATE = 'objectEndDate'
    private_constant :OBJECT_END_DATE
    ROLE = 'artistRole'
    private_constant :ROLE
    BIO = 'artistDisplayBio'
    private_constant :BIO
    CLASSIFICATION = 'classification'
    private_constant :CLASSIFICATION
    PUBLIC_DOMAIN = 'isPublicDomain'
    private_constant :PUBLIC_DOMAIN
    DEPARTMENT = 'department'
    private_constant :DEPARTMENT
    REPOSITORY = 'repository'
    private_constant :REPOSITORY

    # Builds the creator for the row.
    # @return [Proc] a proc that traject can call for each record
    def generate_creator
      lambda do |record, accumulator, _context|
        accumulator << [record[DISPLAY_NAME], record[SUFFIX],
                        artist_role_bio(record)].select(&:present?).join(', ').presence
      end
    end

    # Builds the object date for the record.
    # @return [Proc] a proc that traject can call for each record
    def generate_object_date
      lambda do |record, accumulator, _context|
        object_date = record[OBJECT_BEGIN_DATE] unless record[OBJECT_BEGIN_DATE].to_s.empty?
        object_date = "#{object_date} - #{record[OBJECT_END_DATE]}" unless record[OBJECT_END_DATE].to_s.empty?
        accumulator << object_date
      end
    end

    # Builds the EDM type for the record.
    # @return [Proc] a proc that traject can call for each record
    def edm_type
      lambda do |record, accumulator, _context|
        accumulator << 'Image' if record[CLASSIFICATION].present?
      end
    end

    # Sets either "Public Domain" or "Not Public Domain" for the record.
    # @return [Proc] a proc that traject can call for each record
    def public_domain
      lambda do |record, accumulator, _context|
        accumulator << 'Public Domain' if record[PUBLIC_DOMAIN]
        accumulator << 'Not Public Domain' unless record[PUBLIC_DOMAIN]
      end
    end

    # Sets the data provider value from the department and repository fields.
    # @note This overrides the DLME macro of the same name
    # @see DLME#data_provider
    # @return [Proc] a proc that traject can call for each record
    def data_provider
      lambda do |record, accumulator, _context|
        accumulator << [record[DEPARTMENT], record[REPOSITORY]].select(&:present?).join(', ').presence
      end
    end

    private

    def artist_date_range(record)
      [record[BEGIN_DATE], record[END_DATE]].select(&:present?).join(' - ')
    end

    def artist_role_bio(record)
      role = [record[ROLE], record[BIO]].select(&:present?).join(' ; ')
      artist_info = artist_date_range(record)
      artist_info += " (#{role})" if role.present?
      artist_info
    end
  end
end
