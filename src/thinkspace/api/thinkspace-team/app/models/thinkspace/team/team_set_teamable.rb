module Thinkspace
  module Team
    class TeamSetTeamable < ActiveRecord::Base
      totem_associations
      validates_presence_of :teamable
      validates_presence_of :thinkspace_team_team_set
    end
 end
end
