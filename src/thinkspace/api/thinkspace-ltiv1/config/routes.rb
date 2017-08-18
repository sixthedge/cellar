Thinkspace::Ltiv1::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/ltiv1' do

      resources :users, only: [] do
        post :sign_in, on: :collection
      end

      resources :contexts, only: [] do
        post :sync, on: :collection
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
