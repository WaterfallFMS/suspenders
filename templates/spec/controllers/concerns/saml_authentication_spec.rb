require 'spec_helper'

class TestController < ApplicationController
end


describe TestController do
  context '.require_login' do
    it 'redirects the user to login_path if not logged in' do
      controller.stub :logged_in? => false

      controller.should_receive(:redirect_to).with(controller.login_path)

      controller.require_login
    end

    it 'does nothing if the user is logged in' do
      controller.stub :logged_in? => true
      controller.should_not_receive :redirect_to

      controller.require_login
    end
  end

  context '.logged_in?' do
    it 'returns true if there is a current_user' do
      controller.current_user = build :user

      expect(controller.logged_in?).to be true
    end

    it 'returns false if there is no current_user' do
      expect(controller.logged_in?).to be false
    end
  end

  context '.login_from_session' do
    it 'check the session cookie for tenant and user id' do
      controller.session.should_receive(:[]).with(:tenant_id).once
      controller.session.should_receive(:[]).with(:user_id).at_least(:once)
      controller.login_from_session
    end

    it 'returns the found user and sets current_user' do
      user = create :user
      controller.session[:tenant_id] = user.tenant_id
      controller.session[:user_id]   = user.id

      expect(controller.login_from_session).to eq user
      expect(controller.current_user).to eq user
    end

    it 'returns false if no user is found' do
      expect(controller.current_user).to be false
    end
  end

  context '.logout' do
    it 'does nothing if there is no user' do
      controller.should_not_receive :reset_session

      controller.logout
    end

    it 'resets the session if a user is logged in' do
      controller.current_user = create :user

      controller.should_receive :reset_session

      controller.logout
    end
  end
end