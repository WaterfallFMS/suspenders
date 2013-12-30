require 'spec_helper'

describe ApplicationPolicy do
  let(:policy) {ApplicationPolicy.new user, object}
  let(:user)   {build :user}
  let(:object) {build :forum}

  context '.can_set?' do
    it 'checks if the attribute exists in permitted_attributes' do
      policy.stub permitted_attributes: [:attrib]

      expect(policy.can_set?(:attrib)).to be_true
      expect(policy.can_set?(:fake)).to be_false
    end
  end
end