Rails.application.routes.draw do
  devise_for :users

  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    # Future admin resources:
    # resources :users
    # resources :challenges
    # resources :rewards
    # resources :settings, only: [:index, :update]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Main app root
  root "home#index"
end
