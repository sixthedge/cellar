module Thinkspace
  module PeerAssessment
    class AssessmentTemplate < ActiveRecord::Base
      totem_associations

      include AASM
     
      aasm column: :state do
        state :user, initial: true
        state :system

        event :publicize do
          transitions from: [:user], to: :system
        end

        event :privatize do
          transitions from: [:system], to: :user
        end
      end
    end
  end
end