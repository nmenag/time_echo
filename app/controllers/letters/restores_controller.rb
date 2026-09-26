module Letters
  class RestoresController < ApplicationController
    before_action :authenticate_user!

    def create
      result = Letters::RestoreService.call(params[:letter_id], current_user_email)

      if result.success?
        redirect_to dashboard_path, notice: t("flash.letter_restored")
      else
        case result.error
        when :not_found
          redirect_to dashboard_path, alert: t("flash.private_or_inaccessible")
        when :unauthorized
          redirect_to dashboard_path, alert: t("flash.unauthorized_action")
        when :cannot_restore
          redirect_to dashboard_path, alert: t("flash.cannot_restore")
        end
      end
    end
  end
end
