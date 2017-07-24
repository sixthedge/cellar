module Thinkspace; module PeerAssessment
  class Review < ActiveRecord::Base
    # Thinkspace::PeerAssessment::Review
    # ---
    totem_associations
    validates :review_set_id, uniqueness: { scope: [:reviewable_type, :reviewable_id] }

    # ### States
    include AASM
   
    aasm column: :state do
      state :neutral, initial: true
      state :approved
      state :sent
      state :submitted

      event :submit do
        transitions from: [:neutral], to: :submitted
      end

      event :approve do
        transitions from: [:neutral, :submitted], to: :approved
      end

      event :unapprove do
        transitions from: [:submitted, :approved], to: :neutral, after: :unlock_phase_for_ownerable
      end

      event :mark_as_sent do
        transitions to: :sent
      end
    end

    # ### Helpers
    def unlock_phase_for_ownerable
      review_set = get_review_set
      review_set.unlock_phase_for_ownerable
    end

    def reset_quantitative_data
      return unless self.value.present?
      val = self.value.deep_dup
      val['quantitative'] = []
      self.value = val
      self.save
    end

    def self.generate_anonymized_review_json(assessment, reviews)
      Thinkspace::PeerAssessment::JsonAnonymizers::Review.new(assessment, reviews).process
    end

    def qualitative_items
      return [] unless value.present? && value.has_key?('qualitative')
      value['qualitative']
    end
    def quantitative_items
      return [] unless value.present? && value.has_key?('quantitative')
      value['quantitative']
    end
    def qualitative_item_values
      values = Hash.new
      qualitative_items.each do |id, attrs|
        feedback_type = attrs['feedback_type']
        value         = attrs['value']
        next unless feedback_type.present? and value.present?
        values[feedback_type] ||= []
        values[feedback_type] << value
      end
      values
    end

    def get_review_set; thinkspace_peer_assessment_review_set; end
    def get_assessment; get_review_set.get_assessment; end
    def get_team_set;   get_review_set.get_team_set; end
    def get_ownerable;  get_review_set.ownerable; end
    def get_authable;   get_assessment.authable; end

    def self.scope_by_review_sets(review_sets)
      where(thinkspace_peer_assessment_review_set: review_sets)
    end

    def self.scope_by_reviewable(reviewable)
      where(reviewable: reviewable)
    end

  end
end; end;