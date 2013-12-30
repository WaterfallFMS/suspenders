module PolicyHelper
  def can?(symbol, object)
    perm = "#{symbol}?"
    policy(object).public_send(perm)
  end

  def cannot?(symbol,object)
    !can?(symbol,object)
  end

  def can_set?(attribute, object)
    policy(object).can_set? attribute
  end

  def cannot_set?(attribute, object)
    !can_set?(attribute,object)
  end
end