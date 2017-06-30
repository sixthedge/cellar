Thinkspace::ReadinessAssurance::Engine.routes.draw do
  namespace :api do
    scope :path => '/thinkspace/readiness_assurance' do

      scope module: :admin do

        resources :irats, only: [] do
          collection do
            post :assessment
            post :to_trat
            post :phase_states
            post :progress_report
          end
        end

        resources :trats, only: [] do
          collection do
            post :assessment
            post :responses
            post :team_users
            post :overview
            post :phase_states
            post :progress_report
          end
        end

        resources :messages, only: [] do
          collection do
            post :to_users
          end
        end

        resources :timers, only: [] do
          collection do
            post :cancel
          end
        end

        resources :assessments, only: [:update] do
          collection do
            post :progress_report
          end
          member do
            post :sync
          end
        end
        
      end

      resources :assessments, only: [:show] do
        member do
          post :teams
          post :view
        end
        collection do
          post :trat_overview
        end
      end

      resources :responses, only: [:show, :update]

      resources :chats, only: [] do
        member do
          post :add
        end
      end

      resources :statuses, only: [] do
        member do
          post :lock
          post :unlock
        end
      end

      concern :invalid, Totem::Core::Routes::Invalid.new(); concerns [:invalid]
    end
  end
end
