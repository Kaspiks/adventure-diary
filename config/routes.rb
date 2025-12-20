Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: [ :show ], controller: "profiles"

  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :roles
    # resources :challenges
    # resources :rewards
    # resources :settings, only: [:index, :update]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
