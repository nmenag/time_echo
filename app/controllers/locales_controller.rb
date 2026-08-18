class LocalesController < ApplicationController
  def create
    session[:locale] = params[:locale]
    redirect_back(fallback_location: root_path)
  end

  def destroy
    session[:locale] = nil
    redirect_back(fallback_location: root_path)
  end
end
