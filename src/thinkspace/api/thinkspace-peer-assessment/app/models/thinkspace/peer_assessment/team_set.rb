module Thinkspace
  module PeerAssessment
    class TeamSet < ActiveRecord::Base
      totem_associations

      # ### States
      include AASM
     
      aasm column: :state do
        state :neutral, initial: true
        state :approved
        state :sent

        event :approve do
          transitions from: [:neutral], to: :approved
        end

        event :unapprove do
          transitions from: [:neutral, :approved], to: :neutral
        end

        event :approve_all do
          transitions from: [:neutral, :approved], to: :approved, after: :approve_all_review_sets
        end

        event :unapprove_all do
          transitions from: [:neutral, :approved], to: :neutral, after: :unapprove_all_review_sets
        end

        event :mark_as_sent do
          transitions from: [:approved], to: :sent, after: :mark_as_sent_review_sets
        end
      end

      def approve_all_review_sets
        thinkspace_peer_assessment_review_sets.each { |review_set| review_set.approve_all! if review_set.may_approve? }
      end

      def unapprove_all_review_sets
        thinkspace_peer_assessment_review_sets.each { |review_set| review_set.unapprove_all! if review_set.may_unapprove? }
      end

      def mark_as_sent_review_sets
        thinkspace_peer_assessment_review_sets.scope_approved.each { |review_set| review_set.mark_as_sent! if review_set.may_mark_as_sent? }
      end

      # ### Helpers
      def get_assessment; thinkspace_peer_assessment_assessment; end

      # ### Scopes
      def self.scope_approved; approved; end # aasm auto-generated scope

      class ScopeError < StandardError; end

    end
  end
end