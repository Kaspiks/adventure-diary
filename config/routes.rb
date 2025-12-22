Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: [ :show ], controller: "profiles"

  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :roles
    resources :settings, only: [:index, :edit, :update] do
      collection do
        patch :bulk_update
      end
    end
    # resources :challenges
    # resources :rewards
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
