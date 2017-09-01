Thinkspace::Stripe::Engine.routes.draw do
  namespace :api do
    scope path: '/thinkspace/stripe' do

      resources :customers, only: [:create, :update] do
        collection do
          post :cancel
          post :reactivate
          post :subscription_status
        end
      end

      resources :webhooks, only: [] do
        collection do
          post :callback
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
