module Thinkspace; module PeerAssessment; module Reconcilers
  class TeamSet

    # ### Thinkspace::PeerAssessment::Reconcilers::TeamSet
    # ----------------------------------------
    #
    # The primary function of this object is to:
    # - generate a 'snapshot' (team_sets, review_sets, reviews) of the new team_set
    # - reassign peer_assessment/team_sets to the new corresponding team
    # - reset quantitative data and unlock the phase for any teams that have changed
    # - notify all teams that need to re-submit their phase


    attr_reader :team_set, :options, :assessment, :assignment, :delta, :team_sets, :team_sets_by_team_id, :review_sets_by_team_set_id

    # ### Initialization
    def initialize(team_set, options={})
      @team_set                   = team_set
      @options                    = options
      @phase                      = options[:phase]
      @assessment                 = options[:componentable]
      @assignment                 = @phase.thinkspace_casespace_assignment
      @delta                      = options[:delta]
      @teams_to_notify            = Array.new
      @team_sets                  = team_set_class.where(assessment_id: @assessment.id)
      @team_sets_by_team_id       = @team_sets.index_by(&:team_id)
      @review_sets_by_team_set_id = review_set_class.where(team_set_id: @team_sets.pluck(:id)).group_by(&:team_set_id)
    end

    # We use a strategy of processing each move rather than each team because we need to know which team a user came from 
    # so we can make changes accordingly. For example, if a user removed from one team and added to another, changes need to be 
    # made to both the original team and the new team.
    #
    # This strategy results in the same number of queries that a 'team by team' method of processing would use, so there is 
    # no performance loss using this strategy.

    # ### Processing
    def process
      process_moves
      reassign_team_sets
      reset_quantitative_data
      notify
    end

    # We implement notify as a public method to be called by the creator of the reconciler in order to avoid potentially multiple
    # reconcilers each sending the user a notification as part of their 'process' method
    def notify
      @teams_to_notify.each do |id|
        team_set = get_team_set_by_team_id(id)
        team_set.thinkspace_peer_assessment_review_sets.each do |review_set|
          mailer_class.notify_quant_data_reset(@assessment, review_set.ownerable).deliver_now
        end
      end
    end
    handle_asynchronously :notify

    private

    # Changes the team_id of all team_sets to the new team's id, as saved in the delta object by the exploder
    def reassign_team_sets
      @delta[:teams].each do |tobj|
        team_set = get_team_set_by_team_id(tobj[:id])
        next if team_set.blank?
        if tobj[:deleted]
          team_set.destroy
        elsif tobj[:new]
          team_set_class.create(assessment_id: @assessment.id, team_id: tobj[:new_id])
        else  
          team_set.team_id = tobj[:new_id]
          team_set.save
        end
      end
    end

    # Processes the changes being made, and modifies the peer assessment team_sets, review_sets, and reviews accordingly
    # => 3*t*m queries, where t is the number of users per team and m is the number of moves
    def process_moves
      @delta[:moves].each do |move| process_move(move) end
    end

    def process_move(move)
      process_mover(move)
      process_move_from(move)
      process_move_to(move)
    end

    # Deletes the mover's previous reviews, creates new reviews for each member of the 'to' team
    def process_mover(move)
      from_team_set = get_team_set_by_team_id(move[:from])
      return unless from_team_set.present?
      to_team_set   = get_team_set_by_team_id(move[:to])
      to_team       = get_delta_team_by_id(move[:to])
      review_set    = get_review_set_for_ownerable(from_team_set.id, move[:id])
      review_set    = review_set_class.create(ownerable_id: move[:id], ownerable_type: user_class.name, team_set_id: to_team_set.id) if (!review_set.present? && to_team_set.present?)
      return unless review_set.present?
      if move[:to].present? && to_team_set.present?
        review_set.team_set_id = to_team_set.id
        review_set.save
        review_set.thinkspace_peer_assessment_reviews.destroy_all
        to_team[:total].each do |reviewable_id|
          review_class.create(reviewable_id: reviewable_id, reviewable_type: user_class.name, review_set_id: review_set.id)
        end
      else
        review_set.destroy
      end
    end

    # Deletes all reviews on the 'from' team where the reviewable is the mover
    def process_move_from(move)
      return unless move[:from]
      team_id  = move[:from]
      team     = get_delta_team_by_id(team_id)
      team_set = get_team_set_by_team_id(team_id)
      return unless team_set.present?
      team[:original].each do |id|
        review_set = get_review_set_for_ownerable(team_set.id, id)
        review     = review_class.find_by(reviewable_id: move[:id], reviewable_type: user_class.name, review_set_id: review_set.id) if review_set.present?
        review.destroy if review.present?
      end
    end

    # Creates new reviews for the 'to' team where the reviewable is the mover
    def process_move_to(move)
      return unless move[:to]
      team_id  = move[:to]
      team     = get_delta_team_by_id(team_id)
      return if team[:new] # new teams will be setup by create_reviews
      team_set = get_team_set_by_team_id(team_id)
      return unless team_set.present?
      team[:total].each do |id|
        review_set = get_review_set_for_ownerable(team_set.id, id)
        review_class.create(reviewable_id: move[:id], reviewable_type: user_class.name, review_set_id: review_set.id) if review_set.present?
      end
    end

    def reset_quantitative_data
      @delta[:teams].each do |team|
        if team[:dirty]
          team_set = get_team_set_by_team_id(team[:id])
          next if team_set.blank?
          team_set.reset_quantitative_data
          @teams_to_notify << team_set.team_id
        end

      end
    end

    # ### Classes
    def user_class;       Thinkspace::Common::User;                     end
    def team_set_class;   Thinkspace::PeerAssessment::TeamSet;          end
    def review_set_class; Thinkspace::PeerAssessment::ReviewSet;        end
    def review_class;     Thinkspace::PeerAssessment::Review;           end
    def mailer_class;     Thinkspace::PeerAssessment::AssessmentMailer; end

    # ### Helpers
    def get_team_set_by_team_id(id); @team_sets_by_team_id[id]; end
    def get_review_set_for_ownerable(team_set_id, ownerable_id); @review_sets_by_team_set_id[team_set_id].find { |rs| rs.ownerable_id == ownerable_id }; end
    def get_delta_team_by_id(id); @delta[:teams].find { |t| t[:id] == id }; end


  end
end; end; end