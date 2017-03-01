module Thinkspace; module Authorization

  class Ability

    include ::CanCan::Ability
    include AbilityUtility
    include AbilityClasses
    include AbilitySpaceIds

    def initialize(user=nil)
      case
      when user.blank?
        cannot :manage, :all
        can :latest_for, Thinkspace::Common::Agreement
      when user.superuser?
        can :manage, :all
      else
        set_abilities(user)
      end
    end

    private

    # ### Shared Helper Methods

    # CanCan default aliases actions:
    # :read   => [:index, :show]
    # :create => [:new]
    # :update => [:edit]
    def set_crud_alias_actions; alias_action :read, :create, :update, :destroy, to: :crud; end

    def set_read_alias_actions; alias_action :index, :show, :select, :view, to: :read; end

  end

end; end
