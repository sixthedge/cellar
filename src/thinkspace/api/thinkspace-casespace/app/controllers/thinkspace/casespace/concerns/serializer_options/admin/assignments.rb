module Thinkspace
  module Casespace
    module Concerns
      module SerializerOptions
        module Admin
          module Assignments

            def templates(serializer_options); end
            
            def update(serializer_options)
              serializer_options.include_metadata
              serializer_options.include_association :thinkspace_casespace_phases
            end

            def create(serializer_options)
              serializer_options.ability_actions :gradebook, :manage_resources, scope: :root
            end
            def phase_order(serializer_options); end
            
            def load(serializer_options)
              serializer_options.include_metadata
              serializer_options.ability_actions :gradebook, :manage_resources, scope: :root
              serializer_options.remove_all_except(
                :thinkspace_casespace_phases,
                :thinkspace_common_space,
                scope: :root
              )
              serializer_options.include_association :thinkspace_casespace_phases
              serializer_options.blank_association   :thinkspace_casespace_phase_states, scope: :thinkspace_casespace_phases
              serializer_options.blank_association   :thinkspace_casespace_phase_scores, scope: :thinkspace_casespace_phases
              serializer_options.include_association :thinkspace_common_configuration, scope: :thinkspace_casespace_phases
            end

            def clone(serializer_options); load(serializer_options); end

            def delete; end
            def phase_componentables(serializer_options); end
            def activate(serializer_options);   end
            def inactivate(serializer_options); end
            def archive(serializer_options); end            

            def self.metadata_assignment(controller, record, ownerable); record.serializer_metadata(ownerable, controller.get_serializer_options); end


          end
        end
      end
    end
  end
end
