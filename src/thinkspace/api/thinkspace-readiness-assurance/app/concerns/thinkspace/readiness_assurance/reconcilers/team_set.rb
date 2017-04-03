module Thinkspace; module ReadinessAssurance; module Reconcilers
  class TeamSet

    attr_reader :team_set, :options, :assessment

    # ### Initialization
    def initialize(team_set, options={})
      @team_set               = team_set
      @options                = options
      @assessment             = options[:componentable]
      @delta                  = Thinkspace::Team::Deltas::TeamSet.new(@team_set).process
      # @transform            = options[:transform] || @team_set.transform
      # @team_set_teams       = @team_set.thinkspace_team_teams
      # @team_set_teams_by_id = @team_set_teams.index_by(&:id)
      # @transform_teams      = @transform['teams']
      # @space                = team_set.get_space
    end

    # ### Process
    def process
      @delta[:teams].each do |tobj|
        if tobj[:new]
          next
        elsif tobj[:deleted]
          Thinkspace::PeerAssessment::TeamSet.find_by(team_id: tobj[:id]).destroy # do we really tho?
        else
          next if tobj[:additions].empty? && tobj[:subtractions].empty?
          puts "tobj ID:", tobj[:id]
          team_set = Thinkspace::PeerAssessment::TeamSet.find_by(team_id: tobj[:id])
          team_set.thinkspace_peer_assessment_review_sets.reset_quantitative_data
          # team_set.thinkspace_peer_assessment_review_sets.unlock
          # team_set.thinkspace_peer_assessment_review_sets.notify_reset
        end
      end
    end

  end
end; end; end