namespace :thinkspace do
  namespace :peer_assessment do
    task :transfer_reviews, [:assessment_id, :team_set1_id, :team_set2_id] => [:environment] do |t, args|

      assessment = Thinkspace::PeerAssessment::Assessment.find(args.assessment_id)
      team_set1  = Thinkspace::Team::TeamSet.find(args.team_set1_id)
      team_set2  = Thinkspace::Team::TeamSet.find(args.team_set2_id)

      old_team_ids = team_set1.thinkspace_team_teams.pluck(:id)
      new_team_ids = team_set2.thinkspace_team_teams.pluck(:id)

      old_team_sets = assessment.thinkspace_peer_assessment_team_sets.where(team_id: old_team_ids)
      new_team_sets = assessment.thinkspace_peer_assessment_team_sets.where(team_id: new_team_ids)

      old_review_sets = Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: old_team_sets.pluck(:id))
      new_review_sets = Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: new_team_sets.pluck(:id))

      old_reviews = Thinkspace::PeerAssessment::Review.where(review_set_id: old_review_sets.pluck(:id))
      new_reviews = Thinkspace::PeerAssessment::Review.where(review_set_id: new_review_sets.pluck(:id))

      new_team_sets.each do |new_team_set|
        new_team_set.get_or_create_review_sets
      end

      old_review_sets.each do |old_review_set|
        new_review_set = new_review_sets.find_by(ownerable: old_review_set.ownerable)
        next unless new_review_set.present?
        new_review_set.create_reviews
        old_review_set.thinkspace_peer_assessment_reviews.each do |old_review|
          new_review = new_review_set.thinkspace_peer_assessment_reviews.find_by(reviewable: old_review.reviewable)
          next unless (new_review.present? && new_review.value.nil?)
          new_review.value = old_review.value
          new_review.state = old_review.state
          new_review.save
        end
        new_review_set.state = old_review_set.state
        new_review_set.save
      end

      old_team_sets.destroy_all

    end
  end
end
