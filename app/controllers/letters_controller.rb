class LettersController < ApplicationController
  before_action :authenticate_user!, only: [ :index ]

  def index
    @letters = UserTimelineQuery.call(current_user_email)

    Analytics::TrackEventService.call("dashboard_viewed", { email: current_user_email })
  end

  def new
    @letter_form = LetterForm.new(email: current_user_email)
  end

  def create
    modified_params = letter_params.to_h
    if user_signed_in?
      modified_params[:email] = current_user_email
    end

    result = Letters::CreateService.call(modified_params)

    if result.success?
      unless user_signed_in?
        Auth::MagicLinkService.generate_and_send(result.letter.email)
      end

      flash[:success_email] = result.letter.email
      flash[:success_deliver_at] = result.letter.deliver_at.to_s

      redirect_to success_letters_path
    else
      @letter_form = LetterForm.new(modified_params)
      result.errors.each do |error|
        @letter_form.errors.add(error.attribute, error.message)
      end
      render :new, status: :unprocessable_entity
    end
  end

  def show
    letter = find_letter

    if letter.nil?
      redirect_to root_path, alert: t("flash.private_or_inaccessible")
      return
    end

    policy = LetterPolicy.new(current_user_email, letter)
    unless @accessed_via_signed_id || policy.show?
      redirect_to root_path, alert: t("flash.unauthorized_view")
      return
    end

    @letter = LetterDecorator.new(letter)

    if @letter.pending?
      @countdown = true
    else
      @countdown = false
      if @letter.opened_at.nil?
        @letter.update(opened_at: Time.current)
        Analytics::TrackEventService.call("letter_opened", { letter_id: @letter.id, email: @letter.email })
      end
      @letter.increment!(:open_count)
    end
  end

  private

  def find_letter
    letter = Letter.find_signed(params[:id])
    if letter
      @accessed_via_signed_id = true
      return letter
    end

    if user_signed_in?
      letter = Letter.find_by(id: params[:id], email: current_user_email)
      return letter if letter
    end

    letter = Letter.find_by(id: params[:id], public: true, status: "delivered")
    letter
  end

  def letter_params
    params.require(:letter_form).permit(
      :title, :email, :content, :deliver_at, :public,
      :prediction_city, :prediction_salary, :prediction_relationship, :prediction_career, :prediction_achievement, :prediction_happiness,
      :happiness_level, :anxiety_level, :motivation_level
    )
  end
end
