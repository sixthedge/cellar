module Thinkspace
  module Casespace
    class AssignmentType < ActiveRecord::Base
      totem_associations

      PEER_EVALUATION     = 'Peer Evaluation'
      READINESS_ASSURANCE = 'Readiness Assurance'

      def get_creator_class

        if pe?
          Thinkspace::PeerAssessment::Creators::Assignment
        elsif rat?
          Thinkspace::ReadinessAssurance::Creators::Assignment
        end

      end

      def pe?; title == PEER_EVALUATION; end
      def rat?; title == READINESS_ASSURANCE; end
    end
  end
end
