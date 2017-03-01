module Thinkspace
  module Casespace
    class AssignmentType < ActiveRecord::Base
      totem_associations

      PEER_EVALUATION          = 'Peer Evaluation'
      READINESS_ASSURANCE_TEST = 'Readiness Assurance Test'

      def get_creator_class

        if pe?
          Thinkspace::PeerAssessment::Creators::Assignment
        elsif rat?
          # TODO
        end

      end

      def pe?; title == PEER_EVALUATION; end
      def rat?; title == READINESS_ASSURANCE_TEST; end
    end
  end
end
