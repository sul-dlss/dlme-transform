# frozen_string_literal: true

module Macros
  # Macros for extracting OpenITI metadata
  # rubocop:disable Metrics/AbcSize
  module OpenITI
    def object_description(config, script) # rubocop:disable Metrics/MethodLength
      lambda do |record, accumulator|
        description = config['obj_descr_en'] if script == 'lat'
        description = config['obj_descr_ar'] if script == 'ar'
        values = {}
        values[:author_ar] = record.fetch('author_ar')
        values[:author_lat] = record.fetch('author_lat')
        values[:text_url] = record.fetch('text_url')
        values[:one2all_data_url] = record.fetch('one2all_data_url')
        values[:one2all_stats_url] = record.fetch('one2all_stats_url')
        values[:one2all_vis_url] = record.fetch('one2all_vis_url')
        values[:pairwise_data_url] = record.fetch('pairwise_data_url')
        values[:uncorrected_ocr_ar] = record.fetch('uncorrected_ocr_ar')
        values[:uncorrected_ocr_en] = record.fetch('uncorrected_ocr_en')
        description %= values
        accumulator.replace([description])
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
