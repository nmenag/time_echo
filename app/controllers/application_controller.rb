class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  def set_locale
    # Support locale from params or session, falling back to default
    if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      session[:locale] = params[:locale].to_sym
    end
    I18n.locale = session[:locale] || I18n.default_locale
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user_email, :user_signed_in?

  private

  def current_user_email
    session[:current_user_email]
  end

  def user_signed_in?
    current_user_email.present?
  end

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: t('flash.login_required')
    end
  end
end
