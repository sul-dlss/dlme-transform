# frozen_string_literal: true

# AUC collection p15795coll8 has incorrect date info except in first dc:date field
to_field 'cho_date_range_norm', extract_oai('dc:date'), first_only, strip, auc_date_range
to_field 'cho_date_range_hijri', extract_oai('dc:date'), first_only, strip, auc_date_range, hijri_range
