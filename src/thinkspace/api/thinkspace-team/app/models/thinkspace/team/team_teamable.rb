module Thinkspace
  module Team
    class TeamTeamable < ActiveRecord::Base
      totem_associations
      validates_presence_of :teamable
      validates_presence_of :thinkspace_team_team
    end
 end
end
