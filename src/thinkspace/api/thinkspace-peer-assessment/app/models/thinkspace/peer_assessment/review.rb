module Thinkspace
  module PeerAssessment
    class Review < ActiveRecord::Base
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

      def self.generate_anonymized_review_json(assessment, reviews)
        results             = {}
        json                = {}
        json[:options]      = get_options(assessment, reviews)
        json[:qualitative]  = {}
        json[:quantitative] = {}

        reviews.each do |review|
          values = review.qualitative_item_values
          values.each do |type, array|
            json[:qualitative][type] ||= []
            json[:qualitative][type] << array
            json[:qualitative][type].flatten!
          end

          values  = review.quantitative_items
          values.each do |id, attrs|
            results[id] ||= []
            value = attrs['value']
            next unless value.present?
            results[id] << value.to_f
          end

          # Sort by category.
          items = assessment.quantitative_items
          items.each do |item|
            id    = item['id']
            label = item['label']
            next unless id.present?
            json[:quantitative][id] ||= {}
            json[:quantitative][id][:label] = label
            json[:quantitative][id][:value] = results[id]
          end
        end

        # Average results
        results.each do |id, array|
          avg         = array.inject(0.0) { |sum, el| sum + el } / array.size
          results[id] = avg.round(2)
        end
        json[:quantitative] = results
        json
      end

      def self.get_options(assessment, reviews)
        options = assessment.options.with_indifferent_access
        add_score_range_to_options(options, assessment, reviews)
        options
      end

      def self.add_score_range_to_options(options, assessment, reviews)
        min, max = assessment.get_min_max_score_for_reviews(reviews.count)
        options  = options.with_indifferent_access
        options[:points] ||= {}
        options[:points][:min] = min
        options[:points][:max] = max
        options
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


    end
  end
end