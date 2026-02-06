Rails.application.routes.draw do
  # Devise routes for Restaurant authentication
  devise_for :restaurants, controllers: { registrations: 'restaurants/registrations' }

  root "restaurants#index"

  get '/about', to: 'about#index', as: :about

  # Public routes - no authentication required
  resources :restaurants, only: [:index, :show] do
    resources :menu_items, only: [:index]
    resources :reservations, only: [:new, :create, :index]
    resources :reviews, only: [:new, :create, :index]
  end

  # Admin routes - authentication required
  namespace :admin do
    resources :restaurants do
      resources :subscriptions, only: [:new, :create, :show]
      resources :reservations, only: [:index, :show, :edit, :update]
      resources :menu_items
      resources :tables
      resources :reviews, only: [:index]
    end
  end
end

