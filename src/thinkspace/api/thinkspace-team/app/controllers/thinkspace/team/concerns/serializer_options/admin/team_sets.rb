module Thinkspace
  module Team
    module Concerns
      module SerializerOptions
        module Admin
          module TeamSets
            
            def create(serializer_options)
              serializer_options.include_association :thinkspace_team_teams, scope: :root
            end

            def show(serializer_options); end
            def select(serializer_options); end
            def update(serializer_options); end
            def destroy(serializer_options); end

            def teams(serializer_options)
              serializer_options.include_association :thinkspace_team_teams, scope: :root
              serializer_options.include_association :thinkspace_team_team_users, scope: :thinkspace_team_teams
            end

          end
        end
      end
    end
  end
end