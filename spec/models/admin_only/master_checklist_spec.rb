require 'rails_helper'


RSpec.describe AdminOnly::MasterChecklist, type: :model do

  let(:child_one) { create(:master_checklist, name: 'child 1') }
  let(:child_two) { create(:master_checklist, name: 'child 2') }
  let(:child_three) { create(:master_checklist, name: 'child 3') }

  let(:two_children) do
    # Can add children to a list either by setting the parent: with a call to the Factory
    # or by using .insert
    list = create(:master_checklist, name: 'two children')
    create(:master_checklist, name: 'child 1', parent: list)
    create(:master_checklist, name: 'child 2', parent: list)
    list
  end

  let(:three_children) do
    # Can add children to a list either by setting the parent: with a call to the Factory
    # or by using .insert
    list = create(:master_checklist, name: 'three children')
    list.insert(child_one)
    list.insert(child_two)
    list.insert(child_three)
    list
  end


  describe 'Factories' do

    it 'default factory is valid' do
      expect(create(:master_checklist)).to be_valid
    end

    it 'arguments passed in are valid' do
      expect(create(:master_checklist, name: 'new entry 1')).to be_valid
      expect(create(:master_checklist, parent_name: 'new entry 1')).to be_valid
    end

    it 'traits are valid' do
      expect(create(:master_checklist, :not_in_use)).to be_valid
    end
  end


  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :displayed_text }
    it { is_expected.to validate_presence_of :list_position }
  end


  describe '.all_as_array_nested_by_name' do
    it "calls all_as_array with order: ['name']" do
      expect(described_class).to receive(:all_as_array).with(order: %w(  name))
      described_class.all_as_array_nested_by_name
    end
  end



  describe '.attributes_displayed_to_users' do
    it 'just displayed_text and description' do
      expect(described_class.attributes_displayed_to_users).to match_array([:displayed_text, :description])
    end
  end


  describe 'children_not_in_use' do

    it 'all children with is_in_use = false' do
      mc_parent = create(:master_checklist)
      child1_not_in_use = create(:master_checklist, name: 'not in use', parent: mc_parent, is_in_use: false)
      create(:master_checklist, name: 'in use 1', parent: mc_parent, is_in_use: true)
      create(:master_checklist, name: 'in use 2', parent: mc_parent, is_in_use: true)

      children_found = mc_parent.children_not_in_use
      expect(children_found.to_a).to match_array([child1_not_in_use])
    end
  end


  describe 'children_in_use' do

    it 'all children with is_in_use = true' do
      mc_parent = create(:master_checklist)
      create(:master_checklist, name: 'not in use', parent: mc_parent, is_in_use: false)
      child2_in_use = create(:master_checklist, name: 'in use 1', parent: mc_parent, is_in_use: true)
      child3_in_use = create(:master_checklist, name: 'in use 2', parent: mc_parent, is_in_use: true)

      children_found = mc_parent.children_in_use
      expect(children_found.to_a).to match_array([child2_in_use, child3_in_use])
    end
  end


  describe 'toggle_is_in_use' do
    it 'sets_in_use to the opposite of whatever is_in_use currently is' do
      mc_in_use = create(:master_checklist)
      expect(mc_in_use).to receive(:set_is_in_use).with(false)
      mc_in_use.toggle_is_in_use

      mc_not_in_use = create(:master_checklist, is_in_use: false)
      expect(mc_not_in_use).to receive(:set_is_in_use).with(true)
      mc_not_in_use.toggle_is_in_use
    end
  end


  describe 'set_is_in_use ' do

    it 'first calls set_is_in_use for all children so any that can be deleted are deleted' do
      master_c = create(:master_checklist, name: 'master_c parent')
      child1 = create(:master_checklist, parent: master_c)
      create(:master_checklist, parent: child1)
      create(:master_checklist, parent: master_c)

      expect(master_c).to receive(:children).and_call_original
      master_c.set_is_in_use
    end

    context 'is now set to in use' do
      it 'calls change_to_being_in_use' do
        master_c = create(:master_checklist, name: 'master_c parent')
        expect(master_c).to receive(:change_to_being_in_use)

        master_c.set_is_in_use(true)
      end
    end

    context 'is now set to is not in use' do
      it 'calls make_unused_or_delete' do
        master_c = create(:master_checklist, name: 'master_c parent')
        expect(master_c).to receive(:delete_or_mark_unused)

        master_c.set_is_in_use(false)
      end
    end

  end


  describe 'change_to_being_in_use' do

    it 'sets is_in_use to true and updates the time it was changed' do
      master_c = create(:master_checklist)
      expect(master_c).to receive(:change_is_in_use).with(true)

      master_c.change_to_being_in_use
    end

    it "inserts itself into the parent's list of children list_positions" do
      parent_mc = create(:master_checklist, name: 'parent')
      master_c = create(:master_checklist, parent: parent_mc, name: 'master c')

      expect_any_instance_of(described_class).to receive(:insert).with(master_c)
      master_c.change_to_being_in_use
    end

  end


  describe 'delete_or_mark_unused' do

    let(:new_master) { create(:master_checklist) }

    it 'checks to see if it can be deleted' do
      expect(new_master).to receive(:can_delete?)
      new_master.delete_or_mark_unused
    end

    context 'cannot be deleted' do

      it 'is marked as no longer being used' do
        allow(new_master).to receive(:can_delete?).and_return false

        expect(new_master).to receive(:mark_as_no_longer_used)
        new_master.delete_or_mark_unused
      end
    end

    context 'can be deleted' do

      it 'is deleted' do
        allow(new_master).to receive(:can_delete?).and_return true

        expect(new_master).to receive(:destroy)
        new_master.delete_or_mark_unused
      end
    end
  end


  describe 'mark_as_no_longer_used' do

    it 'is_in_use is changed to false and the time it is changed is updated' do
      master_c = create(:master_checklist)
      expect(master_c).to receive(:change_is_in_use).with(false)

      master_c.mark_as_no_longer_used
    end

    context 'has a parent' do

      it "removes itself from the parent's list of children list positions" do
        parent_master_c = create(:master_checklist, name: 'parent')
        master_c = create(:master_checklist, parent: parent_master_c, name: 'child master_c') # specifying the parent creates the ancestry (nesting)
        parent_master_c.insert(master_c) # This sets up the list positions

        # TODO Why is this not working?  Why is this expectation not met? The method _is_ being called by this object (the parent).
        # expect(master_c.parent).to receive(:remove_child_from_list_positions).with(master_c)

        # This expectation works. So Mocks.. is not recognizing 'parent_master_c' (some problem with == comparison somewhere?)
        expect_any_instance_of(described_class).to receive(:remove_child_from_list_positions).with(master_c)

        master_c.mark_as_no_longer_used
      end
    end

  end


  describe 'remove_child_from_list_positions' do

    it 'decrements the list position for other children, starting at the list position for the child' do
      master_c = create(:master_checklist, name: 'master_c')
      child1 = create(:master_checklist, parent: master_c, name: 'child1')
      master_c.insert(child1)
      child2 = create(:master_checklist, parent: master_c, name: 'child1')
      master_c.insert(child2)
      child3 = create(:master_checklist, parent: master_c, name: 'child1')
      master_c.insert(child3)

      expect(master_c).to receive(:decrement_child_positions).with(child2.list_position)

      master_c.remove_child_from_list_positions(child2)
    end
  end


  describe 'destroy' do
    it 'calls can_be_destroyed? to check business rules/logic/data before it is actually destroyed' do
      master_c = create(:master_checklist)
      expect(master_c).to receive(:can_be_destroyed?)

      master_c.destroy
    end
  end


  describe 'can_be_destroyed?' do
    it 'throws :abort if it cannot be destroyed' do
      master_c = create(:master_checklist)
      allow(master_c).to receive(:can_delete?).and_return(false)

      expect { master_c.can_be_destroyed? }.to raise_error(UncaughtThrowError)
    end

    it 'true if it can be destroyed' do
      master_c = create(:master_checklist)
      allow(master_c).to receive(:can_delete?).and_return(true)

      expect(master_c.can_be_destroyed?).to be_truthy
    end
  end


  describe 'can_delete?' do

    it 'false if it has children' do
      mc_with_children = create(:master_checklist)
      create(:master_checklist, parent: mc_with_children)
      expect(mc_with_children.can_delete?).to be_falsey
    end



    it 'always false (later version of the model implements more logic)' do
      expect(create(:master_checklist).can_delete?).to be_falsey

      mc_with_uncompleted_uchecklists = create(:master_checklist)
      # create(:user_checklist, checklist: mc_with_uncompleted_uchecklists)
      expect(mc_with_uncompleted_uchecklists.can_delete?).to be_falsey
    end
  end

  describe 'change_is_in_use' do

    it 'updates is_in_use and is_in_use_changed_at' do
      changed_time = Time.zone.now
      mc_in_use = create(:master_checklist)
      expect(mc_in_use).to receive(:update).with({ is_in_use: true, is_in_use_changed_at: changed_time })

      mc_in_use.change_is_in_use(true, changed_time)
    end

    it 'default values: is_in_use = false, changed_at = Time.zone.now' do
      mc_in_use = create(:master_checklist, is_in_use: true)
      changed_time = Time.zone.now
      Timecop.freeze(changed_time) do
        mc_in_use.change_is_in_use
      end
      expect(mc_in_use.is_in_use).to be_falsey
      expect(mc_in_use.is_in_use_changed_at).to eq changed_time
    end
  end


  describe 'can_be_changed?' do

    it 'always true if there are no associated user checklists' do
      new_master = create(:master_checklist)
      expect(new_master.can_be_changed?).to be_truthy
      expect(new_master.can_be_changed?(['flurb'])).to be_truthy
    end

  end


  describe 'display_name_with_depth' do

    it "default prefix string is '-'" do
      expect(two_children.children.first.display_name_with_depth.first).to eq '-'
    end

    it 'can specify the prefix' do
      expect(two_children.children.first.display_name_with_depth(prefix: '@').first).to eq '@'
    end

    it 'prefix is repeated (depth) times and then a space and then the name' do
      grandchild_one = build(:master_checklist, name: 'grandchild_one')
      child_one = two_children.children.first
      child_one.insert(grandchild_one)

      expect(grandchild_one.display_name_with_depth).to eq "-- grandchild_one"
    end
  end


end
