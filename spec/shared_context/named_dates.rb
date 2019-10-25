# Dates that can be used in examples, etc.
#
# Use:
#  require 'shared_context/named_dates'
#
#  within a 'describe' or 'context' block:
#   include_context 'named dates'
#
RSpec.shared_context 'named dates' do

  THIS_YEAR = 2018

  let(:jul_1) { Time.zone.local(THIS_YEAR, 7, 1) }
  let(:nov_29) { Time.zone.local(THIS_YEAR, 11, 29) }
  let(:nov_30) { Time.zone.local(THIS_YEAR, 11, 30) }
  let(:dec_1) { Time.zone.local(THIS_YEAR, 12, 1) }
  let(:dec_2) { Time.zone.local(THIS_YEAR, 12, 2) }
  let(:dec_3) { Time.zone.local(THIS_YEAR, 12, 3) }

  let(:nov_29_last_year) { Time.zone.local(THIS_YEAR - 1, 11, 29) }
  let(:nov_30_last_year) { Time.zone.local(THIS_YEAR - 1, 11, 30) }
  let(:nov_29_next_year) { Time.zone.local(THIS_YEAR + 1, 11, 29) }
  let(:nov_30_next_year) { Time.zone.local(THIS_YEAR + 1, 11, 30) }

  let(:lastyear_dec_2) { Time.zone.local(THIS_YEAR - 1, 12, 2) }
  let(:lastyear_dec_8) { Time.zone.local(THIS_YEAR - 1, 12, 8) }
  let(:lastyear_dec_9) { Time.zone.local(THIS_YEAR - 1, 12, 9) }

  let(:jan_30) { Time.zone.local(THIS_YEAR, 1, 30) }
  let(:feb_1) { Time.zone.local(THIS_YEAR, 2, 1) }
  let(:feb_2) { Time.zone.local(THIS_YEAR, 2, 2) }
  let(:feb_3) { Time.zone.local(THIS_YEAR, 2, 3) }

end
