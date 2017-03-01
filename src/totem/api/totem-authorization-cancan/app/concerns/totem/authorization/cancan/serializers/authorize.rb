module Totem
  module Authorization
    module Cancan
      module Serializers

        # Note: These methods will be called only if an action exists.

        module Authorize
          def totem_authorize_has_many(record, association_name, action)
            record.send(association_name).accessible_by(current_ability, action)
          end

          def totem_authorize_has_one(record, association_name, action)
            association_record = record.send(association_name)
            if association_record.present?
              if current_ability.can?(action, association_record) then return association_record else return nil end
            end
          end
        end

      end
    end
  end
end
