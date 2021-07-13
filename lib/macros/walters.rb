# frozen_string_literal: true

module Macros
  # Macros for extracting values from JSON docs
  module Walters
    CLASSIFICATION = 'Classification'
    private_constant :CLASSIFICATION
    IMAGES = 'Images'
    private_constant :IMAGES
    OBJECT_BEGIN_DATE = 'DateBeginYear'
    private_constant :OBJECT_BEGIN_DATE
    OBJECT_END_DATE = 'DateEndYear'
    private_constant :OBJECT_END_DATE
    OBJECT_NAME = 'ObjectName'
    private_constant :OBJECT_NAME
    THUMBNAIL_URL = 'PrimaryImage'
    private_constant :THUMBNAIL_URL

    # Extracts or builds thumbnail url for the record.
    # @return [Proc] a proc that traject can call for each record
    def generate_has_type
      lambda do |record, accumulator, _context|
        accumulator << record[CLASSIFICATION].split(';')[0].strip.downcase if record[CLASSIFICATION].present?
        accumulator << record[OBJECT_NAME].split(';')[0].strip.downcase if record[CLASSIFICATION].blank? &&
                                                                           record[OBJECT_NAME].present?
        accumulator
      end
    end

    # # Builds the object date for the record.
    # # @return [Proc] a proc that traject can call for each record
    def generate_object_date
      lambda do |record, accumulator, _context|
        begin_date = record[OBJECT_BEGIN_DATE].to_s
        end_date = record[OBJECT_END_DATE].to_s
        accumulator << if begin_date.blank? && end_date.blank?
                         nil
                       elsif begin_date.present? && end_date.present?
                         "#{begin_date} - #{end_date}"
                       elsif begin_date.present? && end_date.blank?
                         begin_date
                       elsif begin_date.blank? && end_date.present?
                         end_date
                       end
      end
    end

    # Extracts or builds thumbnail url for the record.
    # @return [Proc] a proc that traject can call for each record
    def generate_preview
      lambda do |record, accumulator, _context|
        if record[THUMBNAIL_URL].present?
          accumulator << record[THUMBNAIL_URL]['Medium'].gsub('width=150', 'width=400')
        else
          accumulator << record[IMAGES].split(',')[0].delete('.').gsub('jpg', '.jpg').prepend('https://art.thewalters.org/images/art/thumbnails/s_').downcase.gsub('width=150', 'width=400')
        end
      end
    end
  end
end
