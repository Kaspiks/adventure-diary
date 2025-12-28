# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: [:show], controller: "profiles"

  namespace :challenges do
    resources :start_actions, only: [:create]
  end

  resources :challenges, only: [:index, :show]

  namespace :attempts do
    resources :submit_actions, only: [:update]
    post "approve_actions/:id", to: "approve_actions#create", as: :approve_action
    post "reject_actions/:id", to: "reject_actions#create", as: :reject_action
  end

  resources :attempts, only: [:show]

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

    namespace :attempts do
      post "approve_actions/:id", to: "approve_actions#create", as: :approve_action
      post "reject_actions/:id", to: "reject_actions#create", as: :reject_action
    end

    resources :attempts, only: [:index, :show]

    resources :settings, only: [:index, :edit, :update] do
      collection do
        patch :bulk_update
      end
    end

    resources :locations, only: [:index, :new, :create, :edit, :update]
    resources :classification_items, only: [:index]
    resources :classifications, only: [:show]
    resources :classification_values, only: [:new, :create, :edit, :update]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
