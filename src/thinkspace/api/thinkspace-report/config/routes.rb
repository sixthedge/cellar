Thinkspace::Report::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/report' do

    	resources :reports, only: [:index, :destroy] do
        collection do
          post :generate
          get  :access
        end

      end

    end
  end
end
