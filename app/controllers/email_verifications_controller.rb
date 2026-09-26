class EmailVerificationsController < ApplicationController
  def show
    result = Emails::VerifyService.call(params[:token])

    if result.success?
      session[:current_user_email] = result.verified_email.email
      redirect_to dashboard_path, notice: t("flash.email_verified")
    else
      redirect_to login_path, alert: t("flash.invalid_or_expired_verification_token")
    end
  end
end
