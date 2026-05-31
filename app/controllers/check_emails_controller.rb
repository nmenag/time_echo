class CheckEmailsController < ApplicationController
  def show
    @email = params[:email]
  end
end
