module Thinkspace
  module Team
    module Concerns
      module SerializerOptions
        module Teams

          def create(serializer_options)
            serializer_options.authorize_action    :view, :thinkspace_common_users
            serializer_options.remove_association  :authable
            serializer_options.except_attributes   :is_member

            serializer_options.include_association :thinkspace_team_category
            serializer_options.include_association :thinkspace_team_team_users
          end

          def update(serializer_options)
            create(serializer_options)
          end

          def show(serializer_options)
            serializer_options.include_association  :thinkspace_team_set_teamables
            serializer_options.include_association  :thinkspace_team_viewers
            serializer_options.blank_association    :thinkspace_team_team_set
          end

          def select(serializer_options); show(serializer_options); end

          def destroy; end

          def teams_view(serializer_options)
            serializer_options.remove_association  :authable
            serializer_options.remove_association  :thinkspace_common_spaces
            serializer_options.remove_association  :thinkspace_common_users
          end

          def team_users_view(serializer_options)
            serializer_options.remove_association  :thinkspace_common_spaces
            serializer_options.only_attributes     :id, :first_name, :last_name
          end

        end
      end
    end
  end
end
