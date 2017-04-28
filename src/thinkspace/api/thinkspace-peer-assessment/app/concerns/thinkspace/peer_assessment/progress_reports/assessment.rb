module Thinkspace; module PeerAssessment; module ProgressReports
  class Assessment

    # ### Thinkspace::PeerAssessment::ProgressReports::Assessment
    # ----------------------------------------
    #
    # The function of this object is to generate a hash which contains all the peer evaluation data necessary for the progress report

    attr_reader :assessment, :options, :teams, :team_sets, :review_sets

    # ### Initialization
    def initialize(assessment, options={})
      @assessment  = assessment
      @options     = options
      @teams       = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable)
      @team_sets   = Thinkspace::PeerAssessment::TeamSet.where(assessment_id: @assessment.id, team_id: @teams.pluck(:id))
      @review_sets = Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: @team_sets.pluck(:id))
      @data        = { team_sets: Array.new }
    end

    def process
      team_sets.each do |team_set|
        process_team_set(team_set)
      end
      sort_team_sets
      @data[:complete]  = get_complete_data
      @data[:total]     = get_total_data
      return @data
    end

    private

    def process_team_set(team_set)
      team          = get_team_by_id(team_set.team_id)
      team_set_data = get_data_for_team_set(team_set)

      team.thinkspace_common_users.order(:first_name, :last_name).each do |user|
        review_set = get_review_set_by_ownerable(team_set, user)
        team_set_data[:review_sets] << get_data_for_review_set(review_set, user)
      end

      @data[:team_sets] << team_set_data
    end

    def get_data_for_team_set(team_set)
      team         = get_team_by_id(team_set.team_id)
      num_total    = team.thinkspace_common_users.count
      num_complete = team_set.thinkspace_peer_assessment_review_sets.to_a.count { |rs| rs.status == 'complete' }
      {
        id:           team_set.id,
        title:        team.title,
        num_total:    num_total,
        num_complete: num_complete,
        num_ignored:  num_total - num_complete,
        state:        team_set.state,
        color:        team.color,
        review_sets:  Array.new
      }
    end

    def get_data_for_review_set(review_set, user)
      id        = if review_set.present? then review_set.id     else nil           end
      state     = if review_set.present? then review_set.state  else 'neutral'     end
      status    = if review_set.present? then review_set.status else 'not started' end
      {
        id:             id,
        name:           user.full_name,
        color:          user.color,
        state:          state,
        status:         status,
        ownerable_id:   user.id,
        ownerable_type: user.class.name.underscore
      }
    end

    def get_complete_data
      {
        review_sets: @review_sets.to_a.count { |rs| rs.status == 'complete' },
        team_sets:   @data[:team_sets].count { |tsd| tsd[:num_complete] == tsd[:num_total] }
      }
    end

    def get_total_data
      {
        review_sets: Thinkspace::Team::TeamUser.where(team_id: @teams.pluck(:id)).count,
        team_sets:   @team_sets.count
      }
    end

    def sort_team_sets; @data[:team_sets] = @data[:team_sets].sort { |a,b| a[:title] <=> b[:title] }; end
    def get_review_set_by_ownerable(team_set, ownerable); @review_sets.find_by(ownerable: ownerable, team_set_id: team_set.id); end
    def get_team_by_id(id); @teams.find_by(id: id); end

  end
end; end; end