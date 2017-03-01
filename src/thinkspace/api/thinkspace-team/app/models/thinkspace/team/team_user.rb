module Thinkspace
  module Team
    class TeamUser < ActiveRecord::Base
      totem_associations
      after_save do
        raise "team_id is blank" if self.team_id.blank?
        raise "user_id is blank" if self.user_id.blank?
      end
    end
 end
end