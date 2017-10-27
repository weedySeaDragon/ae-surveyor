class UsersController < ApplicationController

  before_action :authorize_user
  before_action :set_user, except: [:welcome, :index]


  def welcome

  end


  def update

    if @user.update(user_params)
      redirect_to @user, notice: t('surveyor.users.update.success')
    else
      helpers.flash_message(:alert, t('surveyor.users.update.error'))

      @user.errors.full_messages.each { |err_message| helpers.flash_message(:alert, err_message) }

      render @user
    end

  end


  private

  def authorize_user
    authorize User
  end


  def set_user
    @user = User.find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :greeting, :email, :password, :password_confirmation)
  end


end
