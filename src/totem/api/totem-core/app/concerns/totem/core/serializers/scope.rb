module Totem
  module Core
    module Serializers

      class Scope

        attr_accessor :current_user
        attr_accessor :current_ability
        attr_accessor :serializer_options

        def initialize
        end

        def ability_read_all;   @current_ability = AbilityRead.new;   end
        def ability_manage_all; @current_ability = AbilityManage.new; end
        def ability_current_user
          raise "Current user must be set before calling ability_current_user."  if current_user.blank?
          @current_ability = ::Totem::Settings.authorization.current_ability_class(current_user).new(current_user)
        end

        private

        class AbilityRead
          include ::CanCan::Ability
          def initialize; can :read, :all; end
        end

        class AbilityManage
          include ::CanCan::Ability
          def initialize; can :manage, :all; end
        end

      end

    end
  end
end     