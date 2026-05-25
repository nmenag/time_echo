class LettersController < ApplicationController
  before_action :authenticate_user!, only: [ :index ]

  # Dashboard: timeline/history of letters
  def index
    @letters = UserTimelineQuery.call(current_user_email)

    # Track dashboard view
    Analytics::TrackEventService.call("dashboard_viewed", { email: current_user_email })
  end

  # Public feed of letters
  def public_feed
    @letters = PublicLettersQuery.call
  end

  # Create future letter page
  def new
    @letter_form = LetterForm.new(email: current_user_email)
  end

  # Create a letter
  def create
    modified_params = letter_params.to_h
    if user_signed_in?
      modified_params[:email] = current_user_email
    end

    result = Letters::CreateService.call(modified_params)

    if result.success?
      flash[:success_email] = result.letter.email
      flash[:success_deliver_at] = result.letter.deliver_at.to_s

      redirect_to success_letters_path
    else
      @letter_form = LetterForm.new(modified_params)
      # Copy errors
      result.errors.each do |error|
        @letter_form.errors.add(error.attribute, error.message)
      end
      render :new, status: :unprocessable_entity
    end
  end

  # Open / show a letter (securely via signed_id or logged in session)
  def show
    @letter = find_letter

    if @letter.nil?
      redirect_to root_path, alert: t("flash.private_or_inaccessible")
      return
    end

    policy = LetterPolicy.new(current_user_email, @letter)
    unless @accessed_via_signed_id || policy.show?
      redirect_to root_path, alert: t("flash.unauthorized_view")
      return
    end

    # If the letter is not delivered yet, show a countdown page rather than the content
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

  # Post endpoint to update predictions reality
  def update_predictions
    @letter = find_letter
    if @letter.nil? || @letter.pending?
      redirect_to root_path, alert: t("flash.private_or_inaccessible")
      return
    end

    policy = LetterPolicy.new(current_user_email, @letter)
    unless @accessed_via_signed_id || policy.show?
      redirect_to root_path, alert: t("flash.unauthorized_modify")
      return
    end

    Letter.transaction do
      # Update reveal emotions if provided
      @letter.update!(
        reveal_happiness: params[:reveal_happiness],
        reveal_anxiety: params[:reveal_anxiety],
        reveal_motivation: params[:reveal_motivation]
      )

      # Update predictions
      if params[:predictions].present?
        params[:predictions].each do |pred_id, pred_params|
          prediction = @letter.predictions.find_by(id: pred_id)
          if prediction
            prediction.update!(
              reality: pred_params[:reality],
              matched: ActiveModel::Type::Boolean.new.cast(pred_params[:matched])
            )
          end
        end
      end

      # Track events in analytics
      Analytics::TrackEventService.call("prediction_completion", { letter_id: @letter.id, email: @letter.email })
      Analytics::TrackEventService.call("emotional_snapshot_completion", { letter_id: @letter.id, email: @letter.email })
    end

    flash[:success] = t("flash.reality_updated")
    redirect_to letter_path(@letter)
  end

  # Success page
  def success
    @email = flash[:success_email]
    @deliver_at = flash[:success_deliver_at] ? Time.parse(flash[:success_deliver_at]) : nil

    if @email.nil?
      redirect_to root_path
    end
  end

  private

  def find_letter
    # 1. Try finding by signed ID (from email)
    letter = Letter.find_signed(params[:id])
    if letter
      @accessed_via_signed_id = true
      return letter
    end

    # 2. If logged in, find by standard ID matching user email
    if user_signed_in?
      letter = Letter.find_by(id: params[:id], email: current_user_email)
      return letter if letter
    end

    # 3. If public and delivered, allow anyone to view by ID
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
