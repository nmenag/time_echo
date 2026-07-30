class LetterPredictionsController < ApplicationController
  def update
    result = Letters::UpdatePredictionsService.call(
      params[:letter_id],
      params,
      current_user_email
    )

    if result.success?
      flash[:success] = t("flash.reality_updated")
      redirect_to letter_path(result.letter)
    else
      case result.error
      when :not_found
        redirect_to root_path, alert: t("flash.private_or_inaccessible")
      when :unauthorized
        redirect_to root_path, alert: t("flash.unauthorized_modify")
      else
        redirect_to root_path, alert: result.message || "Error al guardar los ajustes."
      end
    end
  end
end
