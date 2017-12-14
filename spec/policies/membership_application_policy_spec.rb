require 'rails_helper'


describe MembershipApplicationPolicy do

  let(:admin) { create(:user, email: 'admin@shf.se', admin: true) }

  let(:member_not_owner) { create(:member_with_membership_app, email: 'member_not_owner@random.com') }
  let(:member_applicant) { create(:member_with_membership_app, email: 'member_owner@random.com') }

  let(:user_applicant) { create(:user, email: 'user_applicant@random.com') }
  let(:user_not_owner) { create(:user, email: 'user_not_owner@random.com') }

  let(:application) { create(:membership_application,
                             user: user_applicant,
                             state: :under_review) }

  let(:visitor) { build(:visitor) }


  let(:crud_actions) { [:new, :create, :index, :show, :edit, :update, :destroy] }
  let(:app_state_change_actions) { [:accept, :reject, :need_info, :cancel_need_info, :start_review] }


  describe 'changing the application state attribute, given a controller action' do

    describe 'for a Visitor' do
      subject { described_class.new(visitor, application) }

      it 'forbits create' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:create)
      end

      it 'forbids edit' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:edit)
      end
      it 'forbids update' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:update)
      end
      it 'forbids destroy' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:destroy)
      end

      it 'forbids see (show)' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:show)
      end
    end


    describe 'Member or User not the owner - :state assignment only allowed for new, create' do

      { 'Member': :member_not_owner,
        'User': :user_not_owner }.each do |user_class, current_user|

        describe "For #{user_class} (not the owner of the application)" do

          it 'forbids new' do
            expect(described_class.new(self.send(current_user), application)).to forbid_mass_assignment_of(:state).for_action(:new)
          end

          it 'forbids create ' do
            expect(described_class.new(self.send(current_user), application)).to forbid_mass_assignment_of(:state).for_action(:create)
          end

          it 'forbids show' do
            expect(described_class.new(self.send(current_user), application)).to forbid_mass_assignment_of(:state).for_action(:show)
          end

          it 'forbids edit' do
            expect(described_class.new(self.send(current_user), application)).to forbid_mass_assignment_of(:state).for_action(:edit)
          end

          it 'forbids update' do
            expect(described_class.new(self.send(current_user), application)).to forbid_mass_assignment_of(:state).for_action(:update)
          end

          it 'forbids destroy' do
            expect(described_class.new(self.send(current_user), application)).to forbid_mass_assignment_of(:state).for_action(:destroy)
          end

        end

      end

    end


    describe 'for User that is the owner of the SHFApplication' do
      subject { described_class.new(user_applicant, application) }

      it 'permits show' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:show)
      end

      it 'permits create' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:create)
      end

      it 'permits edit' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:edit)
      end

      it 'permits update' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:update)
      end

      it 'forbids destroy' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:destroy)
      end
    end


    describe 'For the Member owner of the application' do

      subject { described_class.new(member_applicant, member_applicant.membership_applications.first) }

      it 'forbids new for a new application' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:new)
      end

      it 'forbids create for a new application' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:create)
      end

      it 'permits show' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:show)
      end

      it 'forbids edit' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:edit)
      end

      it 'forbids update' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:update)
      end

      it 'forbids destroy' do
        is_expected.to forbid_mass_assignment_of(:state).for_action(:destroy)
      end

    end


    describe 'for Admins' do
      subject { described_class.new(admin, application) }

      it 'permits show the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:show)
      end

      it 'permits create a state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:create)
      end

      it 'permits do all actions with #state' do
        is_expected.to permit_mass_assignment_of(:state)
      end

      it 'permits edit the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:edit)
      end

      it 'permits update the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:update)
      end

      it 'permits destroy the state' do
        is_expected.to permit_mass_assignment_of(:state).for_action(:destroy)
      end
    end

  end


  describe 'actions on the membership application' do


    describe 'For visitors (not logged in)' do
      subject { described_class.new(visitor, application) }

      it 'forbids :information' do
        is_expected.to forbid_action :information
      end

      it 'forbids all CRUD actions' do
        is_expected.to forbid_actions(crud_actions)
      end

      it 'forbids all application state change actions' do
        is_expected.to forbid_actions app_state_change_actions
      end

    end


    describe 'Member or User not the owner can only create a new one and view information' do

      { 'Member': :member_not_owner,
        'User': :user_not_owner }.each do |user_class, current_user|

        describe "For #{user_class} (not the owner of the application)" do

          it 'permits new for a new application (not already instantiated)' do
            expect(described_class.new(self.send(current_user), MembershipApplication)).to permit_action :new
          end

          it 'forbids new for an existing application (already instantiated)' do
            expect(described_class.new(self.send(current_user), application)).to forbid_action :new
          end

          it 'permits create for a new application (not already instantiated)' do
            expect(described_class.new(self.send(current_user), MembershipApplication)).to forbid_action :create
          end

          it 'forbids create for an existing application (already instantiated)' do
            expect(described_class.new(self.send(current_user), application)).to forbid_action :create
          end

          it 'forbids all other CRUD actions (that are not :new or :create)' do
            expect(described_class.new(self.send(current_user), application)).to forbid_actions(crud_actions - [:new, :create])
          end

          it 'forbids all application state change actions' do
            expect(described_class.new(self.send(current_user), application)).to forbid_actions app_state_change_actions
          end

          it 'permits :information' do
            expect(described_class.new(self.send(current_user), application)).to permit_action :information
          end

        end
      end

    end


    describe 'For User that is the owner of the SHFApplication' do
      subject { described_class.new(user_applicant, application) }

      it 'permits new for a new application (not already instantiated)' do
        expect(described_class.new(user_applicant, MembershipApplication)).to permit_action :new
      end

      it 'forbids new for an existing application (already instantiated)' do
        is_expected.to forbid_action :new
      end

      it 'forbids create for a new application (not already instantiated)' do
        expect(described_class.new(user_applicant, MembershipApplication)).to forbid_action :create
      end

      it 'permits create for an existing application (already instantiated)' do
        is_expected.to permit_action :create
      end

      it 'permits show' do
        is_expected.to permit_action :show
      end

      it 'forbids index' do
        is_expected.to forbid_action :index
      end

      describe 'permits changes (:edit, :update) when application is not approved or rejected' do

        it 'application is new' do
          is_expected.to permit_actions [:edit, :update]
        end

        it 'application is under_review' do
          is_expected.to permit_actions [:edit, :update]
        end

        it 'application is waiting_for_applicant' do
          is_expected.to permit_actions [:edit, :update]
        end

        it 'application is ready_for_review' do
          is_expected.to permit_actions [:edit, :update]
        end

      end

      it 'forbids edit for an approved application' do
        application.accept
        is_expected.to forbid_action :edit
      end

      it 'forbids edit for a rejected application' do
        application.reject
        is_expected.to forbid_action :edit
      end

      it 'permits update when the application is not approved or rejected' do
        # TODO
        is_expected.to permit_action :update
      end

      it 'forbids update for an approved application' do
        application.accept
        is_expected.to forbid_action :update
      end

      it 'forbids update for a rejected application' do
        application.reject
        is_expected.to forbid_action :update
      end

      it 'forbids destroy' do
        is_expected.to forbid_action :destroy
      end

      it 'forbids all application state change actions' do
        is_expected.to forbid_actions app_state_change_actions
      end

      it 'permits :information' do
        is_expected.to permit_action :information
      end

    end


    describe 'For Member that is the owner of the MembershipApplication' do
      subject { described_class.new(member_applicant, member_applicant.membership_applications.first) }

      it 'permits new for a new application (not already instantiated)' do
        expect(described_class.new(member_applicant, MembershipApplication)).to permit_action :new
      end

      it 'forbids new for an existing application (already instantiated)' do
        is_expected.to forbid_action :new
      end

      it 'permits create for a new application (not already instantiated)' do
        expect(described_class.new(member_applicant, MembershipApplication)).to forbid_action :create
      end

      it 'forbids create for an existing application (already instantiated)' do
        is_expected.to permit_action :create
      end

      it 'permits show' do
        is_expected.to permit_action :show
      end

      it 'forbids index' do
        is_expected.to forbid_action :index
      end

      it 'forbids changing or deleting the application [:edit, :update, :destroy]' do
        is_expected.to forbid_actions [:edit, :update, :destroy]
      end

      it 'forbids all application state change actions' do
        is_expected.to forbid_actions app_state_change_actions
      end

      it 'permits :information' do
        is_expected.to permit_action :information
      end

    end


    describe 'For Admins' do
      subject { described_class.new(admin, application) }

      it 'forbids new (not already instantiated)' do
        is_expected.to forbid_action :new
      end

      it 'forbids create (already instantiated)' do
        is_expected.to forbid_action :create
      end

      it 'permits show' do
        is_expected.to permit_action :show
      end
      it 'permits index' do
        is_expected.to permit_action :index
      end

      it 'permits edit' do
        is_expected.to permit_action :edit
      end
      it 'permits update' do
        is_expected.to permit_action :update
      end

      it 'permits destroy' do
        is_expected.to permit_action :destroy
      end

      it 'permits accept' do
        is_expected.to permit_action :accept
      end

      it 'permits reject' do
        is_expected.to permit_action :reject
      end

      it 'permits need_info' do
        is_expected.to permit_action :need_info
      end

      it 'permits cancel_need_info' do
        is_expected.to permit_action :cancel_need_info
      end

      it 'permits cancel_need_info' do
        is_expected.to permit_action :cancel_need_info
      end

      it 'permits start_review' do
        is_expected.to permit_action :start_review
      end

    end
  end

end
