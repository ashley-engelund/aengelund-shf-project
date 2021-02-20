# Steps for creating and working with Memberships

# This should match any of the following
#  the following memberships exist
#  the following memberships exist:
Given(/^the following memberships exist(?:[:])?$/) do |table|

  table.hashes.each do |membership_line|
    membership_line['membership_number'] = nil if membership_line['membership_number'].blank?
    membership_line['notes'] = nil if membership_line['notes'].blank?

    user_email = membership_line.delete('email')
    first_day = membership_line.delete('first_day') || nil
    last_day = membership_line.delete('last_day') || nil

    begin
      user = User.find_by(email: user_email)
    rescue => e
      raise e, "Could not find either the user with the email #{user_email}\n #{e.inspect} in 'the following memberships exist'"
    end

    FactoryBot.create(:membership, user: user, first_day: first_day, last_day: last_day)
  end
end
