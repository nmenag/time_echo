module Settings
  class UpdatePreferencesService
    def self.call(user_preference, params, current_user_email)
      new(user_preference, params, current_user_email).call
    end

    def initialize(user_preference, params, current_user_email)
      @user_preference = user_preference
      @params = params.to_h
      @current_user_email = current_user_email
    end

    def call
      new_email = @params[:email]

      if new_email.present? && new_email.strip.downcase != @current_user_email
        result = Settings::RequestEmailUpdateService.call(@user_preference, new_email, @current_user_email)
        if result.success?
          Result.new(
            success: true,
            action: :email_update_requested,
            message: "Hemos enviado un correo de confirmación a tu nueva dirección: #{new_email.strip.downcase}. Por favor, haz clic en el enlace para confirmar y activar el cambio. ✨"
          )
        else
          Result.new(success: false, error: result.error)
        end
      else
        if @user_preference.update(@params.except(:email))
          Analytics::TrackEventService.call(
            "settings_updated",
            { email: @current_user_email, changed_keys: @params.keys }
          ) rescue nil

          Result.new(
            success: true,
            action: :preferences_updated,
            message: "Ajustes guardados ✨"
          )
        else
          Result.new(success: false, error: "No se pudieron guardar los ajustes.")
        end
      end
    end

    class Result
      attr_reader :action, :message, :error
      def initialize(success:, action: nil, message: nil, error: nil)
        @success = success
        @action = action
        @message = message
        @error = error
      end

      def success?
        @success
      end
    end
  end
end
