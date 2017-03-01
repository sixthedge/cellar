Thinkspace::Casespace::Engine.routes.draw do
  namespace :api do
    scope path: '/thinkspace/casespace' do
      # Admin block needs to be first, otherwise it may collide with normal resources.
      # e.g. /users/select?ids=# would be interpreted as /users/:id with id: 'select' if this was not first.
      scope module: :admin do
        resources :assignments, only: [:create, :update] do
          get :templates, on: :collection
          member do
            put    :phase_order
            get    :load
            get    :phase_componentables
            post   :clone
            delete :delete
            put    :activate
            put    :inactivate
            put    :archive
          end
        end

        resources :phases, only: [:update, :destroy] do
          get  :templates,       on: :collection
          post :clone,           on: :collection
          post :bulk_reset_date, on: :collection
          member do
            put :activate
            put :archive
            put :inactivate
            get :componentables
            put :delete_ownerable_data
          end
        end
      end

      # Non-admin
      resources :assignments, only: [:show] do
        collection do
          get :select
        end
        member do
          post :view
          post :roster
          get  :phase_states
        end
      end

      resources :assignment_types, only: [:index, :show] do
        collection do
          get :select
        end
      end

      resources :phases, only: [:show] do
        collection do
          get :select
        end
        member do
          get  :load
          put  :submit
        end
      end

      resources :phase_states, only: [:create, :update] do
        member do
          put  :roster_update
        end
      end

      resources :phase_scores, only: [:create, :update]
      resources :phase_templates, only: [:show] do
        collection do
          get :select
        end
      end
      resources :phase_components, only: [:show] do
        collection do
          get :select
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
