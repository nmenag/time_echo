class LettersController < ApplicationController
  before_action :authenticate_user!, only: [ :index, :show, :destroy ]

  def index
    @letters = UserTimelineQuery.call(current_user_email)
    @archived_letters = Letter.archived.for_email(current_user_email)

    Analytics::TrackEventService.call("dashboard_viewed", { email: current_user_email })
  end

  def new
    @letter_form = LetterForm.new(email: current_user_email)
  end

  def create
    result = Letters::CreateService.call(
      params: letter_params,
      current_user_email: current_user_email
    )

    if result.success?
      flash[:success_email] = result.letter.email
      flash[:success_deliver_at] = result.letter.deliver_at.to_s

      redirect_to success_letters_path
    else
      @letter_form = result.form
      render :new, status: :unprocessable_entity
    end
  end

  def show
    result = Letters::AccessService.call(params[:id], current_user_email)

    if result.success?
      @letter = LetterDecorator.new(result.letter)
      @countdown = result.countdown?
    else
      case result.error
      when :not_found
        redirect_to root_path, alert: t("flash.private_or_inaccessible")
      when :unauthorized
        redirect_to root_path, alert: t("flash.unauthorized_view")
      end
    end
  end

  def destroy
    result = Letters::DestroyService.call(params[:id], current_user_email)

    if result.success?
      redirect_to dashboard_path, notice: t("flash.letter_archived")
    else
      case result.error
      when :not_found
        redirect_to dashboard_path, alert: t("flash.private_or_inaccessible")
      when :unauthorized
        redirect_to dashboard_path, alert: t("flash.unauthorized_action")
      when :cannot_archive_delivered
        redirect_to dashboard_path, alert: t("flash.cannot_archive_delivered")
      end
    end
  end

  private

  def letter_params
    params.require(:letter_form).permit(
      :title, :email, :content, :deliver_at, :scheduled_at, :timezone, :language,
      :prediction_city, :prediction_salary, :prediction_relationship, :prediction_career, :prediction_achievement, :prediction_happiness,
      :happiness_level, :anxiety_level, :motivation_level
    )
  end
end
