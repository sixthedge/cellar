module Thinkspace; module Authorization
class ThinkspaceTeam < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def team
    return unless ns_exists?('Thinkspace::Team')
    team = get_class 'Thinkspace::Team::Team'
    return if team.blank?
    team_set      = Thinkspace::Team::TeamSet
    team_category = Thinkspace::Team::TeamCategory
    team_user     = Thinkspace::Team::TeamUser
    team_teamable = Thinkspace::Team::TeamTeamable
    team_viewer   = Thinkspace::Team::TeamViewer
    can [:read], team_category
    can [:read, :teams_view, :team_users_view, :read_commenterable], team
    return unless admin?
    can [:create, :update, :destroy, :gradebook], team
    can [:crud, :teams, :abstract], team_set
    can [:read, :create, :destroy], [team_teamable, team_user, team_viewer]
  end

end; end; end
