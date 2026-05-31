class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_preference

  def show
    # Find or create user creation date based on their oldest letter, fallback to today
    @account_created_at = Letter.where(email: current_user_email).order(:created_at).first&.created_at || @user_preference.created_at || Time.current
  end

  def update
    old_email = current_user_email
    new_email = params.dig(:user_preference, :email)&.strip&.downcase

    if new_email.present? && new_email != old_email
      # Validate email format
      unless new_email.match?(URI::MailTo::EMAIL_REGEXP)
        flash.now[:alert] = "Por favor introduce un correo electrónico válido."
        render :show, status: :unprocessable_entity
        return
      end

      # Check if another UserPreference already exists for new_email
      existing_pref = UserPreference.find_by(email: new_email)

      ActiveRecord::Base.transaction do
        # 1. Update all letters
        Letter.where(email: old_email).update_all(email: new_email)
        
        # 2. Update user preferences
        if existing_pref
          @user_preference.destroy!
          @user_preference = existing_pref
        else
          @user_preference.update!(email: new_email)
        end
        
        # 3. Update active session
        session[:current_user_email] = new_email
      end

      redirect_to settings_path, notice: "Correo electrónico actualizado correctamente ✨"
      return
    end

    if @user_preference.update(settings_params)
      # Record an analytics event for settings update
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
    # Clean-wipe all data associated with current_user_email
    email = current_user_email

    ActiveRecord::Base.transaction do
      letters = Letter.where(email: email)
      letter_ids = letters.pluck(:id)

      if letter_ids.any?
        conn = ActiveRecord::Base.connection
        # Clean delete all foreign-key child entries using direct SQL statements
        %w[reactions comments goals predictions emotional_snapshots].each do |table|
          conn.execute(conn.sanitize_sql_array([ "DELETE FROM #{table} WHERE letter_id IN (?)", letter_ids ])) rescue nil
        end
      end

      letters.destroy_all

      # 2. Delete user preferences
      @user_preference.destroy!

      # 3. Clean analytics events associated
      AnalyticsEvent.where("metadata ->> 'email' = ?", email).delete_all rescue nil
    end

    # Clear session and redirect to landing
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
