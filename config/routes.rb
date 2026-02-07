Rails.application.routes.draw do
  # Devise routes for Restaurant authentication
  devise_for :users,
             path: "",
             path_names: { sign_in: "login", sign_out: "salir", sign_up: "registro" }

  devise_for :restaurants,
             path: "resto",
             path_names: { sign_in: "login", sign_out: "salir", sign_up: "registro" },
             controllers: { registrations: "restaurants/registrations" }

  namespace :users do
    resources :reservations, only: [:index, :destroy]
  end

  root "restaurants#index"

  get '/about', to: 'about#index', as: :about

  # Public routes - no authentication required
  resources :restaurants, only: [:index, :show] do
    resources :menu_items, only: [:index]
    resources :reservations, only: [:new, :create]
    resources :reviews, only: [:new, :create, :index, :destroy]
  end

  # Admin routes - authentication required
  namespace :admin do
    resources :restaurants, only: [:index, :show, :edit, :update, :destroy] do
      member do
        get :confirm_delete
        delete :menu_file
      end
      delete :photo, on: :member
      resources :subscriptions, only: [:new, :create, :show] do
        collection do
          get :success
          get :cancel
        end
      end
      resources :reservations, only: [:index, :show, :edit, :update]
      resources :menu_items
      resources :tables
      resources :reviews, only: [:index, :show, :destroy]
    end
  end

  post "/webhooks/stripe", to: "stripe_webhooks#create"
end
