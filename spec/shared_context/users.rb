require 'shared_context/named_dates'

# This creates these users: (all use create() unless "[uses build()]" is noted in the description below)
#   (Note that 'shared_context/named_dates' defines THIS_YEAR; last year = THIS_YEAR - 1; next year = THIS_YEAR + 1)
#
# user - a user (no payments, not a member)
# user_no_payments - a user (no payments, not a member)
# member_paid_up - [uses build(), then saves] a member with a membership application and a membership payment made today
# member_expired - [uses build(), then saves] a member with a membership application and a membership payment that expired yesterday
# user_pays_every_nov30 - current member with membership app; paid membership fee Nov 30 last year; paid branding fee Nov 30 last year; paid membership fee Nov 30 THIS_YEAR; paid branding fee Nov 30 THIS_YEAR;
# user_paid_only_lastyear_dec_2 - member with membership app; paid membership fee Dec 2 last year; paid branding fee Dec 2 last year
# user_paid_lastyear_nov_29 - member with membership app; paid membership fee Nov 29 last year; paid branding fee Nov 29 last year
# user_unsuccessful_this_year - member with membership app; unsuccessful membership fee Nov 29 THIS_YER; unsuccessful branding fee Nov 29 THIS_YEAR; successful membership fee Nov 30 last year; successful branding fee Nov 30 last year
# user_membership_expires_EOD_jan29 - member with membership app; membership term and branding fee term expire end of day (EOD) Jan 29 next year
# user_membership_expires_EOD_jan30 - member with membership app; membership term and branding fee term expire end of day (EOD) Jan 30 next year
# user_membership_expires_EOD_jan31 - member with membership app; membership term and branding fee term expire end of day (EOD) Jan 31 next year
# user_membership_expires_EOD_feb1 - member with membership app; membership term and branding fee term expire end of day (EOD) Feb 1 next year
# user_membership_expires_EOD_feb2 - member with membership app; membership term and branding fee term expire end of day (EOD) Feb 2 next year
# user_membership_expires_EOD_dec7 - member with membership app; membership term and branding fee term expire end of day (EOD) Dec 7 next year
# user_membership_expires_EOD_dec8 - member with membership app; membership term and branding fee term expire end of day (EOD) Dec 8 next year
# user_membership_expires_EOD_dec9 - member with membership app; membership term and branding fee term expire end of day (EOD) Dec 8 next year
#
# TODO - DRY up by defining a method that creates the user, payments, company for a given start day (and any other arguments needed)
#
RSpec.shared_context 'create users' do

  include_context 'named dates'

  let(:user) { create(:user) }

  let(:member_paid_up) do
    user = build(:member_with_membership_app)
    user.payments << create(:membership_fee_payment)
    user.save!
    user
  end

  let(:member_expired) do
    user = build(:member_with_membership_app)
    user.payments << create(:expired_membership_fee_payment)
    user.save!
    user
  end


  let(:user_pays_every_nov30) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_nov_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_30,
             expire_date: User.expire_date_for_start_date(lastyear_nov_30),
             notes:       'lastyear_nov_30 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_30,
             expire_date: Company.expire_date_for_start_date(lastyear_nov_30),
             notes:       'lastyear_nov_30 branding')
    end

    Timecop.freeze(nov_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30,
             expire_date: User.expire_date_for_start_date(nov_30),
             notes:       'nov_30 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30,
             expire_date: Company.expire_date_for_start_date(nov_30),
             notes:       'nov_30 branding')
    end

    u
  end


  let(:user_paid_only_lastyear_dec_2) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_2) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_2,
             expire_date: User.expire_date_for_start_date(lastyear_dec_2),
             notes:       'lastyear_dec_2 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_2,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_2),
             notes:       'lastyear_dec_2 branding')
    end
    u
  end


  let(:user_paid_lastyear_nov_29) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_nov_29) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_29,
             expire_date: User.expire_date_for_start_date(lastyear_nov_29),
             notes:       'lastyear_nov_29 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_29,
             expire_date: Company.expire_date_for_start_date(lastyear_nov_29),
             notes:       'lastyear_nov_29 branding')
    end
    u
  end


  let(:user_unsuccessful_this_year) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    # success on nov 30 last year
    Timecop.freeze(lastyear_nov_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_30,
             expire_date: User.expire_date_for_start_date(lastyear_nov_30),
             notes:       'lastyear_nov_30 success membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_30,
             expire_date: Company.expire_date_for_start_date(lastyear_nov_30),
             notes:       'lastyear_nov_30 success branding')
    end

    # failed on nov 29
    Timecop.freeze(nov_29) do
      create(:membership_fee_payment,
             :expired,
             user:        u,
             company:     u_co,
             start_date:  nov_29,
             expire_date: User.expire_date_for_start_date(nov_29),
             notes:       'nov_29 failed (expired) membership')
      create(:h_branding_fee_payment,
             :expired,
             user:        u,
             company:     u_co,
             start_date:  nov_29,
             expire_date: Company.expire_date_for_start_date(nov_29),
             notes:       'nov_29 failed (expired) branding')
    end

    u
  end


  let(:user_no_payments)     { create(:user) }


  let(:user_membership_expires_EOD_jan29) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(jan_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  jan_30,
             expire_date: User.expire_date_for_start_date(jan_30),
             notes:       'jan_30 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  jan_30,
             expire_date: Company.expire_date_for_start_date(jan_30),
             notes:       'jan_30 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_jan30) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(jan_31) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  jan_31,
             expire_date: User.expire_date_for_start_date(jan_31),
             notes:       'jan_31 membership; expires jan 30 next year')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  jan_31,
             expire_date: Company.expire_date_for_start_date(jan_31),
             notes:       'jan_31 branding; expires jan 30 next year')
    end

    u
  }

  let(:user_membership_expires_EOD_jan31) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(feb_1) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_1,
             expire_date: User.expire_date_for_start_date(feb_1),
             notes:       'feb_1 membership; expires jan 31 next year')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_1,
             expire_date: Company.expire_date_for_start_date(feb_1),
             notes:       'feb_1 branding; expires jan 31 next year')
    end

    u
  }

  let(:user_membership_expires_EOD_feb1) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(feb_2) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_2,
             expire_date: User.expire_date_for_start_date(feb_2),
             notes:       'feb_2 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_2,
             expire_date: Company.expire_date_for_start_date(feb_2),
             notes:       'feb_2 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_feb2) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(feb_3) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_3,
             expire_date: User.expire_date_for_start_date(feb_3),
             notes:       'feb_3 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  feb_3,
             expire_date: Company.expire_date_for_start_date(feb_3),
             notes:       'feb_3 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_dec7) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_8) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_8,
             expire_date: User.expire_date_for_start_date(lastyear_dec_8),
             notes:       'lastyear_dec_8 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_8,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_8),
             notes:       'lastyear_dec_8 branding')
    end

    u
  }

  let(:user_membership_expires_EOD_dec8) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_9) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_9,
             expire_date: User.expire_date_for_start_date(lastyear_dec_9),
             notes:       'lastyear_dec_9 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_9,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_9),
             notes:       'lastyear_dec_9 branding')
    end

    u
  }


  let(:user_membership_expires_EOD_dec9) {
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_10) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_10,
             expire_date: User.expire_date_for_start_date(lastyear_dec_10),
             notes:       'lastyear_dec_10 membership; expires dec 9')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_10,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_10),
             notes:       'lastyear_dec_10 branding; expires dec 9')
    end

    u
  }

end
