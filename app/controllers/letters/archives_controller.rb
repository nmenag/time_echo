module Letters
  class ArchivesController < ApplicationController
    before_action :authenticate_user!

    def create
      result = Letters::ArchiveService.call(params[:letter_id], current_user_email)

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
  end
end
