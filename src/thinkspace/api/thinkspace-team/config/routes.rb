Thinkspace::Team::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/team' do

      scope module: :admin do
        resources :team_sets, only: [:create, :show, :update, :destroy] do
          get :select, on: :collection
          get :teams, on: :member
        end 

        resources :teams, only: [:create, :update, :destroy]
        resources :team_users,      only: [:create, :destroy]
        resources :team_viewers,    only: [:create, :destroy]
        resources :team_teamables,  only: [:create, :destroy]

      end

      resources :teams, only: [:show] do
        collection do
          post :teams_view
          post :team_users_view
          get  :select
        end
      end

      resources :team_categories, only: [:index, :show]
      resources :team_sets,       only: [:show]

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
