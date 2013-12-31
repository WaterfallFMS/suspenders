require 'spec_helper'

class FakePolicy < ApplicationPolicy
  def show?
    false
  end
end


describe PolicyHelper do
  before do
    helper.stub(:policy) do |model|
      policy
    end
  end
  let(:policy) {FakePolicy.new user, object}
  let(:user)   {build :user}
  let(:object) {build :user}

  context '.can?' do
    it 'sends the ? method to the policy object' do
      policy.should_receive(:show?)

      helper.can? :show, object
    end
  end

  context '.cannot?' do
    it 'calls can? and negates it' do
      helper.should_receive(:can?).and_return false

      expect(helper.cannot?(:show, object)).to be_true
    end
  end

  context '.can_set?' do
    it 'calls can_set? on the policy' do
      policy.should_receive(:can_set?)

      helper.can_set?(:fake, object)
    end
  end

  context '.cannot_set?' do
    it 'calls can_set? and negates it' do
      policy.should_receive(:can_set?).and_return false

      expect(helper.cannot_set?(:fake, object)).to be_true
    end
  end
end