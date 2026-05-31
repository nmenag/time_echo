class LetterPredictionsController < ApplicationController
  def update
    letter = find_letter
    if letter.nil? || letter.pending?
      redirect_to root_path, alert: t("flash.private_or_inaccessible")
      return
    end

    policy = LetterPolicy.new(current_user_email, letter)
    unless @accessed_via_signed_id || policy.show?
      redirect_to root_path, alert: t("flash.unauthorized_modify")
      return
    end

    Letter.transaction do
      letter.update!(
        reveal_happiness: params[:reveal_happiness],
        reveal_anxiety: params[:reveal_anxiety],
        reveal_motivation: params[:reveal_motivation]
      )

      if params[:predictions].present?
        params[:predictions].each do |pred_id, pred_params|
          prediction = letter.predictions.find_by(id: pred_id)
          if prediction
            prediction.update!(
              reality: pred_params[:reality],
              matched: ActiveModel::Type::Boolean.new.cast(pred_params[:matched])
            )
          end
        end
      end

      Analytics::TrackEventService.call("prediction_completion", { letter_id: letter.id, email: letter.email })
      Analytics::TrackEventService.call("emotional_snapshot_completion", { letter_id: letter.id, email: letter.email })
    end

    flash[:success] = t("flash.reality_updated")
    redirect_to letter_path(letter)
  end

  private

  def find_letter
    letter = Letter.find_signed(params[:letter_id])
    if letter
      @accessed_via_signed_id = true
      return letter
    end

    if user_signed_in?
      letter = Letter.find_by(id: params[:letter_id], email: current_user_email)
      return letter if letter
    end

    letter = Letter.find_by(id: params[:letter_id], public: true, status: "delivered")
    letter
  end
end
