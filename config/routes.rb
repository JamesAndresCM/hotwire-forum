Rails.application.routes.draw do
  resources :categories
  devise_for :users
  resources :discussions, only: %i[index create new edit update destroy show] do
    resources :posts, only: %i[create show edit update destroy], module: :discussions

    collection do
      get 'category/:id', to: 'categories/discussions#index', as: :category
    end

    resources :notifications, only: :create, module: :discussions
  end

  resources :notifications, only: :index do
    collection do
      post '/mark_as_read', to: 'notifications#read_all', as: :read
    end
  end

  root 'main#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
