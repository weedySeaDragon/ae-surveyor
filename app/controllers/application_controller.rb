class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  include Pundit


  protect_from_forgery with: :exception
  before_action :set_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  def index

  end

  private

  def set_locale
    @locale = I18n.default_locale
    @locale = params[:locale].to_s if params[:locale].present?
    I18n.locale = @locale
  end

  def default_url_options
    {locale: I18n.locale}
  end


  def after_sign_in_path_for(resource)

    if resource.admin?
      admin_root_path
    else
      user_path resource
    end

  end

  def user_not_authorized
    flash[:alert] = t('surveyor.errors.not_authorized')
    redirect_back(fallback_location: root_path)
  end


end
