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

  resources :attempts, only: [:show, :edit, :update]

  get "my/attempts", to: "attempts#index", as: :my_attempts

  # Rewards catalog
  resources :rewards, only: [:index, :show]
  namespace :rewards do
    post "purchase_actions/:reward_id", to: "purchase_actions#create", as: :purchase_actions
  end

  # User orders
  resources :orders, only: [:index, :show]

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
    resources :order_statuses, only: [:index, :new, :create, :edit, :update]
    resources :attempt_statuses, only: [:index, :new, :create, :edit, :update]
    resources :classification_items, only: [:index]
    resources :classifications, only: [:show]
    resources :classification_values, only: [:new, :create, :edit, :update]

    # Rewards management
    resources :rewards do
      member do
        get :orders
      end
    end

    # Orders management
    resources :orders, only: [:index, :show]
    namespace :orders do
      post "status_actions/:id/approve", to: "status_actions#approve", as: :status_action_approve
      post "status_actions/:id/deliver", to: "status_actions#deliver", as: :status_action_deliver
      post "status_actions/:id/cancel", to: "status_actions#cancel", as: :status_action_cancel
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
