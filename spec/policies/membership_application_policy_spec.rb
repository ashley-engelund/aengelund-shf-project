require 'rails_helper'


describe MembershipApplicationPolicy do

  let(:application_owner) { create(:user, email: 'user_1@random.com') }
  let(:admin) { create(:user, email: 'admin@sgf.com', admin: true) }

  let(:application) { create(:membership_application,
                             user: application_owner) }

  subject { described_class.new(application_owner, application) }


  describe 'For the MembershipApplication creator' do
    subject { described_class.new(application_owner, application) }

    it 'can show #status' do
      is_expected.to permit_mass_assignment_of(:status).for_action(:show)
    end

    it 'can create #status' do
      is_expected.to permit_mass_assignment_of(:status).for_action(:create)
    end

    it 'cannot edit, update, or destroy #status' do
      is_expected.to forbid_mass_assignment_of(:status)
    end

  end


  describe 'For admins' do
    subject { described_class.new(admin, application) }

    it 'can do all actions with #status' do
      is_expected.to permit_mass_assignment_of(:status)
    end

  end

end