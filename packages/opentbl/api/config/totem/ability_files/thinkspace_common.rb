module Thinkspace; module Authorization
class ThinkspaceCommon < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  protected

  def read_space;              {id: read_space_ids}.merge(read_states); end
  def read_space_association;  {thinkspace_common_space:  read_space}; end
  def read_spaces_association; {thinkspace_common_spaces: read_space}; end
  def with_read_space_ids;     {space_id: read_space_ids}; end

  def admin_space;              get_admin_spaces_ability.merge(admin_states); end
  def admin_space_association;  {thinkspace_common_space:  admin_space}; end
  def admin_spaces_association; {thinkspace_common_spaces: admin_space}; end

  def read_states;  {state: ['active']}; end
  def admin_states; {state: ['active', 'inactive']}; end

  def get_admin_spaces_ability
    @_admin_spaces_ability ||= begin
      case
      when iadmin?   then {institution_id: admin_institution_ids}
      when admin?    then {id: admin_space_ids}
      else Hash.new
      end
    end
  end

  private

  def domain
    can [:read], Thinkspace::Common::SpaceType
    can [:read], Thinkspace::Common::Configuration
    can [:read], Thinkspace::Common::Component
    can [:read], Thinkspace::Common::Color
  end

  def spaces
    space = Thinkspace::Common::Space
    can [:create], space
    can :read, space, read_space
    return unless admin_ability?
    can :read, space, admin_space
    can [:update, :clone, :import, :invite, :roster, :invitations, :teams, :team_sets, :search], space, admin_space
  end

  def space_users
    space_user = Thinkspace::Common::SpaceUser
    can [:read_space_owners, :view], space_user, with_read_space_ids
    return unless admin_ability?
    can [:read, :update, :destroy, :resend, :inactivate, :activate], space_user, admin_space_association
  end

  def users
    user           = Thinkspace::Common::User
    password_reset = Thinkspace::Common::PasswordReset
    can [:create, :sign_in, :sign_out, :stay_alive, :validate, :view, :switch, :avatar, :update_tos], user
    can [:read, :update], user, {id: current_user.id}
    can [:create, :read, :update], password_reset
    can [:read_space_owners, :read_commenterable], user, read_spaces_association
    can [:read_teammates], user
    cannot [:select], user
    return unless admin_ability?
    can [:read, :select, :gradebook, :refresh], user, admin_spaces_association
  end

  def disciplines
    discipline = Thinkspace::Common::Discipline
    can [:read], discipline
  end

  def agreements
    agreement = Thinkspace::Common::Agreement
    can [:read, :latest_for], agreement
  end

end; end; end
