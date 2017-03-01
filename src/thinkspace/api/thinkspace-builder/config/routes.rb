Thinkspace::Builder::Engine.routes.draw do
  namespace :api do
    scope path: '/thinkspace/builder' do

      resources :templates, only: [:index]

      # Admin block needs to be first, otherwise it may collide with normal resources.
      # e.g. /users/select?ids=# would be interpreted as /users/:id with id: 'select' if this was not first.
      # scope module: :admin do
      #   resources :assignments, only: [:create, :update] do
      #     get :templates, on: :collection
      #     member do
      #       put    :phase_order
      #       get    :load
      #       post   :clone
      #       delete :delete
      #     end
      #   end

      #   resources :phases, only: [:update, :destroy] do
      #     get  :componentables, on: :member
      #     get  :templates,      on: :collection
      #     post :clone,          on: :collection
      #   end
      # end

      # # Non-admin
      # resources :assignments, only: [:show] do
      #   collection do
      #     get :select
      #   end
      #   member do
      #     post :view
      #     post :roster
      #     get  :phase_states
      #   end
      # end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
