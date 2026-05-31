class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_preference

  def show
    @account_created_at = Letter.where(email: current_user_email).order(:created_at).first&.created_at || @user_preference.created_at || Time.current
  end

  def update
    old_email = current_user_email
    new_email = params.dig(:user_preference, :email)

    if new_email.present? && new_email.strip.downcase != old_email
      result = Settings::RequestEmailUpdateService.call(@user_preference, new_email, old_email)
      if result.success?
        redirect_to settings_path, notice: "Hemos enviado un correo de confirmación a tu nueva dirección: #{new_email.strip.downcase}. Por favor, haz clic en el enlace para confirmar y activar el cambio. ✨"
      else
        flash.now[:alert] = result.error
        render :show, status: :unprocessable_entity
      end
      return
    end

    if @user_preference.update(settings_params.except(:email))
      AnalyticsEvent.create!(
        event_type: "settings_updated",
        occurred_at: Time.current,
        metadata: { email: current_user_email, changed_keys: settings_params.keys }
      ) rescue nil

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Ajustes actualizados correctamente ✨"
          render turbo_stream: [
            turbo_stream.replace("flash-container", partial: "shared/flash")
          ]
        end
        format.html { redirect_to settings_path, notice: "Ajustes guardados ✨" }
      end
    else
      flash.now[:alert] = "No se pudieron guardar los ajustes."
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    Settings::DestroyAccountService.call(current_user_email, @user_preference)
    session[:current_user_email] = nil
    redirect_to root_path, notice: "Tu baúl y todos tus datos han sido borrados de forma permanente. Gracias por tu tiempo en TimeEcho."
  end

  private

  def set_user_preference
    @user_preference = UserPreference.find_or_create_by!(email: current_user_email)
  end

  def settings_params
    params.require(:user_preference).permit(
      :email,
      :future_letter_reminders,
      :monthly_checkpoints,
      :surprise_memories,
      :emotional_summary_emails,
      :appearance_mode,
      :theme,
      :all_letters_private,
      :automatic_memories,
      :anonymous_analytics,
      :reflection_style,
      :memory_frequency
    )
  end
end
