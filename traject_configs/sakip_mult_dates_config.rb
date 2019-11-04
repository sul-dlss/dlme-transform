# frozen_string_literal: true

to_field 'cho_date_range_norm', extract_oai('dc:date'), sakip_mult_dates_range
to_field 'cho_date_range_hijri', extract_oai('dc:date'), sakip_mult_dates_range, hijri_range
