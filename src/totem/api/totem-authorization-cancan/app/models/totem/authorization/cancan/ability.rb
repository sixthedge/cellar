module Totem
  module Authorization
    module Cancan

      class Ability
        include ::CanCan::Ability

        def initialize(user=nil)
          set_guest(user)
        end

        def set_alias_actions
          alias_action :create, :read, :update, :destroy, :to => :crud
        end

        def set_guest(user)
          set_alias_actions
          cannot :manage, :all
        end

      end

    end
  end
end