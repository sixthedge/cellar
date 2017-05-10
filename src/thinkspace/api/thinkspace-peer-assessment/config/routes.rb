Thinkspace::PeerAssessment::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/peer_assessment' do
      # Admin
      scope module: :admin do
        resources :assessments, only: [:update] do
          get  :teams,       on: :member
          get  :review_sets, on: :member
          get  :team_sets,   on: :member
          put  :approve,     on: :member
          put  :activate,    on: :member
          get  :progress_report, on: :member
          put  :approve_team_sets, on: :member
        end

        resources :reviews, only: [] do
          member do
            put :approve
            put :unapprove
          end
        end

        resources :review_sets, only: [] do
          member do
            put  :ignore
            put  :unignore
            put  :unlock
            put  :remind
          end
        end

        resources :team_sets, only: [:show] do
          member do
            put :approve
            put :unapprove
            put :approve_all
            put :unapprove_all
          end
        end
      end

      # Non-admin
      resources :assessment_templates, only: [:index, :show, :create] do
        get :select, on: :collection
        get :user_templates, on: :collection
      end

      resources :assessments, only: [:show] do
        get :view, on: :member
        get :fetch, on: :collection
      end
      resources :review_sets, only: [] do
        put :submit, on: :member
      end
      resources :reviews, only: [:create, :update]
      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
