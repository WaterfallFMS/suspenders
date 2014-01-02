class RootController < ApplicationController
  skip_before_filter :require_login,        :only => :index
  skip_after_filter  :verify_policy_scoped, :only => :index

  def index
    if logged_in?
      redirect_to forums_path
    end
  end
  
  def internal
  end
end