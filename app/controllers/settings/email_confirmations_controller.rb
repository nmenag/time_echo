module Settings
  class EmailConfirmationsController < ApplicationController
    def show
      result = Settings::ConfirmEmailUpdateService.call(params[:token])

      if result.success?
        session[:current_user_email] = result.new_email
        redirect_to settings_path, notice: t("settings.email_confirmed")
      else
        redirect_to settings_path, alert: "El enlace de confirmación no es válido o ha caducado."
      end
    end
  end
end
