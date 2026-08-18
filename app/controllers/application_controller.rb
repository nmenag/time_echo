class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :set_locale

  def set_locale
    locale = session[:locale]&.to_sym
    if locale.nil? || !I18n.available_locales.include?(locale)
      locale = request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first&.to_sym
    end
    if locale && I18n.available_locales.include?(locale)
      I18n.locale = locale
    end
  end

  stale_when_importmap_changes

  helper_method :current_user_email, :user_signed_in?, :current_user_theme, :toggle_locale

  private

  def toggle_locale
    I18n.locale == :en ? :es : :en
  end

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
