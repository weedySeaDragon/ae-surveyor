class AdminController < ApplicationController

  before_action :authorize_admin



  private

  def authorize_admin
    AdminPolicy.new(current_user).authorized?
  end


end
