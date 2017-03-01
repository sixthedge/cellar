module Totem
  module Authorization
    module Cancan
      module Controllers
        module CurrentAbility

          def current_ability
            @current_ability ||= get_ability
          end

          def get_ability
            platform_ability || framework_ability || nil
          end

          def platform_ability(object = self)
            ability_class = ::Totem::Settings.authorization.current_ability_class(object)
            ability_class && ability_class.new(current_user)
          end

          def framework_ability
            get_platform_name_ability(::Totem::Settings.registered.framework_name)
          end

        end
      end
    end
  end
end
