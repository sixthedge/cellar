module Thinkspace
  module Team
    class TeamCategory < ActiveRecord::Base
      totem_associations
      validates_presence_of :category

      # Supported category column values.
      PEER_REVIEW   = 'peer_review'
      COLLABORATION = 'collaboration'
      ASSESSMENT    = 'assessment'

      # ###
      # ### Class Helpers.
      # ###
      def self.peer_review;   find_by(category: PEER_REVIEW); end
      def self.collaboration; find_by(category: COLLABORATION); end
      def self.assessment;    find_by(category: ASSESSMENT); end

      # ###
      # ### Instance Helpers.
      # ###
      def peer_review?;    self.category == PEER_REVIEW;   end
      def collaboration?;  self.category == COLLABORATION; end
      def assessment?;     self.category == ASSESSMENT;    end
      def team_ownerable?; collaboration?; end

    end
  end
end