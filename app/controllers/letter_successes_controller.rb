class LetterSuccessesController < ApplicationController
  def show
    @email = flash[:success_email]
    @deliver_at = flash[:success_deliver_at] ? Time.parse(flash[:success_deliver_at]) : nil

    if @email.nil?
      redirect_to root_path
    end
  end
end
