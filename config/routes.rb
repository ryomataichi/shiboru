Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :shizens do
    resources :likes, only: [:create, :destroy]
    resources :comments, only: [:create]
    member do
      delete :purge_image
    end
  end

  get 'shizens/:shizen_id/likes' => 'likes#create'
  get 'shizens/:shizen_id/likes/:id' => 'likes#destroy'
  get "shizens/matome/:id" => "shizens#matome", as: :shizen_matome
  get "/refresh_weather", to: "shizens#refresh_weather"

  resources :users, only: [:index, :show, :edit, :update] do
    resource :relationships, only: [:create, :destroy]
      get "followings" => "relationships#followings", as: "followings"
      get "followers" => "relationships#followers", as: "followers"
  end
  resources :messages, :only => [:create]
  resources :rooms, :only => [:create, :show]
  get "users/match/:bangou" => "users#match", as: :users_match 
  get "users/dmitiran/:id" => "users#dmitiran", as: :users_dmitiran
  get "users/iine/:id" => "users#iine", as: :users_iine
  root 'shizens#index'
end