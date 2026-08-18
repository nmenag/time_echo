class LetterSuccessesController < ApplicationController
  def show
    @email = flash[:success_email]
    @deliver_at = flash[:success_deliver_at] ? Time.parse(flash[:success_deliver_at]) : nil
    @seal_date_display = I18n.l(Date.current, format: :default)
    @deliver_at_display = @deliver_at ? I18n.l(@deliver_at.to_date, format: :long) : t("letters.success_date_fallback")

    if @email.nil?
      redirect_to root_path
    end
  end
end
