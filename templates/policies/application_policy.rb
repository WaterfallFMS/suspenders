class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def role
    user.account_type =~ /admin/ ? :admin : :user
  end

  def permitted_attributes
    raise 'permitted attributes not defined'
  end

  def can_set?(attribute)
    permitted_attributes.include? attribute
  end
end

