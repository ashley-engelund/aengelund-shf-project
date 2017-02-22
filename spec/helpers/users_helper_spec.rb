require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  let!(:user) { create(:user) }
  let(:right_now) { Time.now }
  let(:yesterday) { Time.now - 60*60*24 - 120}

  describe '#most_recent_login_time' do

    it 'returns nil if the user has never logged in' do
      expect(helper.most_recent_login_time(user)).to be_nil
    end

    it 'returns the current_sign_in_at time if current_sign_in_at is not nil' do
      u = user
      u.update(current_sign_in_at: right_now)
      expect(helper.most_recent_login_time(u)).to eq(right_now)
    end

    it 'returns the current_sign_in_at if it is not nil and there was a last_sign_in_at' do
      u = user
      u.update(current_sign_in_at: right_now, last_sign_in_at: yesterday)
      expect(helper.most_recent_login_time(u)).to eq(right_now)
    end

    it 'returns the last_sign_in_at time if current_sign_in_at is nil' do
      u = user
      u.update(last_sign_in_at: yesterday)
      expect(helper.most_recent_login_time(u)).to eq(yesterday)
    end

  end


  describe '#most_recent_login_ip' do

    it 'returns nil if the user has never logged in' do
      expect(helper.most_recent_login_ip(user)).to be_nil
    end

    it 'returns the current_sign_in_ip if current_sign_in_at is not nil' do
      u = user
      u.update(current_sign_in_ip: '8.8.8.8')
      expect(helper.most_recent_login_ip(u)).to eq('8.8.8.8')
    end

    it 'returns the current_sign_in_ip if it is not nil and there was a last_sign_in_ip' do
      u = user
      u.update(current_sign_in_ip: '8.8.8.8', last_sign_in_ip: '127.0.0.1')
      expect(helper.most_recent_login_ip(u)).to eq('8.8.8.8')
    end


    it 'returns the last_sign_in_ip if current_sign_in_ip is nil' do
      u = user
      u.update( last_sign_in_ip: '127.0.0.1')
      expect(helper.most_recent_login_ip(u)).to eq('127.0.0.1')
    end

  end


end
