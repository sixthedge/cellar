module Thinkspace
  module Casespace
    module Concerns
      module SerializerOptions
        module Admin
          module Phases

            def templates(serializer_options); end
            def clone(serializer_options)
              serializer_options.include_association :thinkspace_common_configuration
              serializer_options.remove_all_except [:thinkspace_common_configuration, :thinkspace_casespace_assignment]
            end
            def create(serializer_options); end
            def update(serializer_options); clone(serializer_options); end
            def bulk_reset_date(serializer_options); end
            def destroy(serializer_options); end
            def componentables(serializer_options); end
            def activate(serializer_options)
              common_state_options(serializer_options)
            end
            def archive(serializer_options)
              common_state_options(serializer_options)
            end
            def inactivate(serializer_options)
              common_state_options(serializer_options)
            end
            def delete_ownerable_data(serializer_options); common_state_options(serializer_options); end

            # ### Helpers
            def common_state_options(serializer_options)
              serializer_options.remove_all_except [:thinkspace_common_configuration, :thinkspace_casespace_assignment]
            end
            
          end
        end
      end
    end
  end
end
