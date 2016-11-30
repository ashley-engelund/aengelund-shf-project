require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_class' do

    it 'adds correct class on notice' do
      expect(helper.flash_class(:notice)).to eq 'success'
    end

    it 'adds correct class on alert' do
      expect(helper.flash_class(:alert)).to eq 'danger'
    end
  end

  describe '#flash_message' do

    before(:each) do
      @flash_type = :blorf
      @first_message = 'first_message'
      @second_message = 'second_message'
      flash[@flash_type] = nil
      helper.flash_message @flash_type, @first_message
    end

    it 'adds message to nil flash[type]' do
      expect(flash[@flash_type].count).to eq 1
      expect(flash[@flash_type].first).to eq @first_message
    end

    it 'adds message to a flash[type] that already has messages' do
      helper.flash_message @flash_type, @second_message
      expect(flash[@flash_type].count).to eq 2
      expect(flash[@flash_type].first).to eq @first_message
      expect(flash[@flash_type].last).to eq @second_message
      expect(flash[@flash_type]).to eq [@first_message, @second_message]

    end
  end
end
