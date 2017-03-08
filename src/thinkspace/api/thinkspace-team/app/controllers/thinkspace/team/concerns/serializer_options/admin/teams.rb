module Thinkspace
  module Team
    module Concerns
      module SerializerOptions
        module Admin
          module Teams
            
            def create(serializer_options)
              serializer_options.include_association :thinkspace_team_teams, scope: :root
              serializer_options.include_association :thinkspace_team_team_users
            end

            def update(serializer_options)
              serializer_options.include_association :thinkspace_team_team_users
            end
            
            def destroy(serializer_options); end

          end
        end
      end
    end
  end
end