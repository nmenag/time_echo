Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Root page
  root "pages#landing"

  # Passwordless Authentication
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  get "login/:token", to: "sessions#show", as: :magic_login
  delete "logout", to: "sessions#destroy", as: :logout
  get "check_email", to: "sessions#check_email", as: :check_email

  # Letters & Digital Vault
  get "letters/success", to: "letters#success", as: :success_letters
  resources :letters, only: [:new, :create, :show] do
    member do
      post :update_predictions
    end
    collection do
      get "public", to: "letters#public_feed", as: :public_feed
    end
  end
  
  # Dashboard
  get "dashboard", to: "letters#index", as: :dashboard

  # Emotional Analytics
  get "analytics", to: "analytics#index", as: :analytics

  # Webhook Delivery Endpoint
  post "webhooks/resend", to: "webhooks#resend"
end
