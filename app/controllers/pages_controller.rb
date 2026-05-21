class PagesController < ApplicationController
  def landing
    if user_signed_in?
      redirect_to dashboard_path
    else
      @public_letters = PublicLettersQuery.call.limit(3)
    end
  end
end
