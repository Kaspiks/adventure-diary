Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: [:show], controller: "profiles"

  resources :challenges, only: [:index, :show] do
    member do
      post :start
    end
  end

  resources :attempts, only: [:show] do
    member do
      patch :submit
      post :approve
      post :reject
    end
  end

  get "my/attempts", to: "attempts#index", as: :my_attempts

  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :roles
    resources :challenges do
      member do
        get :attempts
      end
      collection do
        get :field_template
      end
    end
    resources :attempts, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end
    resources :settings, only: [:index, :edit, :update] do
      collection do
        patch :bulk_update
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
