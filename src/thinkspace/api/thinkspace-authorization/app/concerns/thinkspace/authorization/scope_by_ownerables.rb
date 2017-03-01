module Thinkspace; module Authorization; module ScopeByOwnerables

extend ::ActiveSupport::Concern

module ClassMethods

  def scope_by_ownerables(users, record=nil)

    scope = self.where(ownerable: users)
    return scope if record.blank?

    teamable = nil
    if record.respond_to?(:thinkspace_team_teams)
      teamable = record
    else
      teamable = record.authable  if record.respond_to?(:authable)
      teamable = nil unless teamable.respond_to?(:thinkspace_team_teams)
    end
    return scope if teamable.blank?

    teams = teamable.thinkspace_team_teams.scope_by_users(users)
    scope.or(self.where(ownerable: teams))

  end

end; end; end; end
