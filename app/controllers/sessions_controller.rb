class SessionsController < ApplicationController
  # Render the sign-in form page
  def new
    if current_user_email
      redirect_to dashboard_path
    else
      @magic_link_form = MagicLinkForm.new
    end
  end

  # Create a magic link
  def create
    @magic_link_form = MagicLinkForm.new(session_params)
    if @magic_link_form.submit
      # Track event in Postgres
      Analytics::TrackEventService.call("magic_link_requested", { email: @magic_link_form.email })
      
      redirect_to check_email_path(email: @magic_link_form.email)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Authenticate a magic link token
  def show
    email = Auth::MagicLinkService.authenticate(params[:token])
    if email
      session[:current_user_email] = email
      
      # Track event in Postgres
      Analytics::TrackEventService.call("user_logged_in", { email: email })
      
      redirect_to dashboard_path, notice: "Welcome back to your digital time capsule."
    else
      redirect_to login_path, alert: "This magic link is invalid or has expired."
    end
  end

  # Log out
  def destroy
    email = session[:current_user_email]
    session.delete(:current_user_email)
    
    # Track event in Postgres
    Analytics::TrackEventService.call("user_logged_out", { email: email }) if email
    
    redirect_to root_path, notice: "You have successfully closed your capsule session."
  end

  # Check email page (informative)
  def check_email
    @email = params[:email]
  end

  private

  def session_params
    params.require(:magic_link_form).permit(:email)
  end
end
