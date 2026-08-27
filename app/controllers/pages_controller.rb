class PagesController < ApplicationController
  def landing
    if user_signed_in?
      redirect_to dashboard_path
    end
  end

  def privacy
  end

  def terms
  end

  def about
  end
end
