Thinkspace::Resource::Engine.routes.draw do
  namespace :api do
    scope path: 'thinkspace/resource' do

      resources :files, only: [:create, :show, :update, :destroy] do
        get :select, on: :collection
      end

      resources :links, only: [:create, :show, :update, :destroy] do
        get :select, on: :collection
      end

      resources :tags, only: [:create, :show, :update, :destroy] do
        get :select, on: :collection
      end

    end
  end
end
