# frozen_string_literal: true

# Cambridge collections have TEI <origDate notBefore="yyyy" notAfter="yyyy"> so we can leverage it here
to_field 'cho_date_range_norm', cambridge_gregorian_range
to_field 'cho_date_range_hijri', cambridge_gregorian_range, hijri_range
