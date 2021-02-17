# frozen_string_literal: true

module Macros
  # Macros for extracting Stanford Specific MODS values from Nokogiri documents
  module Manchester
    # Extract Manchester Solar Hijri range from string, ignoring month/day information.
    def manchester_solar_hijri_range
      lambda do |_record, accumulator|
        gregorian_val = []
        if accumulator.present?
          year_val = accumulator.first.split('-').first.split('(').last.delete(')')
          solar_hijri_val = year_val.tr('۱', '1')
                                    .tr('۲', '2')
                                    .tr('۳', '3')
                                    .tr('۴', '4')
                                    .tr('۵', '5')
                                    .tr('۶', '6')
                                    .tr('۷', '7')
                                    .tr('۸', '8')
                                    .tr('۹', '9')
                                    .tr('۰', '0')
          gregorian_val << (solar_hijri_val.to_i + 621) # add year before
          gregorian_val << (solar_hijri_val.to_i + 622)
          gregorian_val << (solar_hijri_val.to_i + 623) # add year after
        end
        accumulator.replace(gregorian_val)
      end
    end
  end
end
