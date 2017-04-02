class UserPolicy <  ApplicationPolicy

  def index?
    is_admin?
  end

  def welcome?
    true
  end


  def show?
    ! @user.nil?
  end

end
