module Settings
  class EmailConfirmationsController < ApplicationController
    def show
      result = Settings::ConfirmEmailUpdateService.call(params[:token])

      if result.success?
        session[:current_user_email] = result.new_email
        redirect_to settings_path, notice: "¡Dirección de correo electrónico confirmada y actualizada con éxito! ✨"
      else
        redirect_to settings_path, alert: "El enlace de confirmación no es válido o ha caducado."
      end
    end
  end
end
