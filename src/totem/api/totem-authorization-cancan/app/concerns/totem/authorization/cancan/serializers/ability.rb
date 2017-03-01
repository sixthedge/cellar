module Totem
  module Authorization
    module Cancan
      module Serializers

        # Note: The method will be called only if an action exists.
        module Ability
          def totem_ability(record, action)
            current_ability.can?(action, record)
          end
        end

      end
    end
  end
end
