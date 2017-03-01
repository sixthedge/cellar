Thinkspace::PubSub::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/pub_sub' do

      resources :authenticate, only: [] do
        collection do
          post :authenticate
        end
      end

      resources :authorize, only: [] do
        collection do
          post :authorize
        end
      end

      resources :server_events, only: [] do
        collection do
          post :load_messages
          post :tracker
          post :timer_cancel
        end
      end

      resources :timers, only: [] do
        collection do
          post :reload
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
