module Thinkspace
  module Team
    class TeamViewer < ActiveRecord::Base
      totem_associations
      validates_presence_of :thinkspace_team_team, :viewerable
    end
 end
end
