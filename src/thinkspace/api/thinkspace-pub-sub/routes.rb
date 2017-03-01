Thinkspace::PeerAssessment::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/peer_assessment' do
      # Admin
      scope module: :admin do
        resources :assessments, only: [:update] do
          get  :teams,       on: :member
          get  :review_sets, on: :member
          get  :team_sets,   on: :member
          get  :fetch,       on: :collection
          put  :approve,     on: :member
          put  :activate,    on: :member
        end

        resources :overviews, only: [:update]

        resources :reviews, only: [] do
          member do
            put :approve
            put :unapprove
          end
        end

        resources :review_sets, only: [] do
          member do
            put  :approve
            put  :unapprove
            post :notify
          end
        end

        resources :team_sets, only: [] do
          member do
            put :approve
            put :unapprove
            put :approve_all
            put :unapprove_all
          end
        end
      end

      # Non-admin
      resources :assessments, only: [:show] do
        get :view, on: :member
      end
      resources :overviews, only: [:show] do
        get :view, on: :member
      end
      resources :review_sets, only: [] do
        put :submit, on: :member
      end
      resources :reviews, only: [:create, :update]
      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
