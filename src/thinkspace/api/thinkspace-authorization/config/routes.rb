Thinkspace::Authorization::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/authorization' do

      resources :abilities, only: [] do
        collection do
          get :abilities
        end
      end

      resources :metadata, only: [] do
        collection do
          get :metadata
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
