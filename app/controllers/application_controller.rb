class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  def set_locale
    I18n.locale = :es
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user_email, :user_signed_in?, :current_user_theme

  private

  def current_user_theme
    if user_signed_in?
      UserPreference.find_by(email: current_user_email)&.theme || "timeecho"
    else
      "timeecho"
    end
  end

  def current_user_email
    session[:current_user_email]
  end

  def user_signed_in?
    current_user_email.present?
  end

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: t("flash.login_required")
    end
  end
end
