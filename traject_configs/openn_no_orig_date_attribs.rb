# frozen_string_literal: true

to_field 'cho_date_range_norm', extract_tei("#{MS_DESC}/#{MS_ORIGIN}/tei:origDate"), extract_gregorian, parse_range
to_field 'cho_date_range_hijri', extract_tei("#{MS_DESC}/#{MS_ORIGIN}/tei:origDate"), extract_or_compute_hijri_range
