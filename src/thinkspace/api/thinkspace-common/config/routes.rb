Thinkspace::Common::Engine.routes.draw do

	namespace :api do
		scope path: '/thinkspace/common/' do
      # Admin block needs to be first, otherwise it may collide with normal resources.
      # e.g. /users/select?ids=# would be interpreted as /users/:id with id: 'select' if this was not first.
      scope module: :admin do
        resources :spaces, only: [:update, :create] do
          member do
            get  :roster
            get  :teams
            get  :team_sets
            post :invite
            post :import
            post :clone
            get  :search
          end
        end

        resources :users, only: [] do
          get :select, on: :collection
          member do
            put  :refresh
            post :switch
            post :is_superuser
          end
        end

        resources :space_users, only: [:update, :destroy] do
          put :resend, on: :member
          put :activate, on: :member
          put :inactivate, on: :member
        end
      end

      # Non-admin
      resources :uploads, only: [] do
        collection do
          post :upload
          get  :sign
          post :confirm
        end
      end

			resources :spaces, only: [:index, :show]

      resources :users, only: [:show, :create, :update] do
        collection do
          post :sign_in
          post :sign_out
          get  :stay_alive
          get  :validate
        end
        member do
          post :avatar
          put  :update_tos
        end
      end
        
      resources :disciplines, only: [:index, :show] do
        collection do
          get :select
        end
      end
        
      resources :agreements, only: [:index, :show] do
        collection do
          get :select
          get :latest_for
        end
      end

      resources :colors, only: [:index, :show] do
        collection do
          get :select
        end
      end
      
      resources :discourse, only: [] do
        post :support, on: :collection
      end

      resources :password_resets, only: [:show, :create, :update]
      resources :components, only: [:show, :index] do
        collection do
          get :select
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]

		end
	end

end
