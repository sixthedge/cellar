module Thinkspace; module Team; module Exploders
  class TeamSet

    # ### Thinkspace::Team::Exploders::TeamSet
    # ----------------------------------------
    #
    # The primary function of this object is to:
    # - generate a new team_set and associated teams based on the transform of the provided team_set
    # - make the new team_set the default team_set
    # - re-assign any current or upcoming assignments to use the new default team_set
    # - reconcile the new team_set with the current and upcoming assignments


    attr_reader :base_team_set, :new_team_set, :options, :transform, :space, :delta

    # ### Initialization
    def initialize(team_set, options={})
      @base_team_set = team_set
      @transform     = team_set.transform
      @options       = options
      @space         = team_set.get_space
      @delta         = Thinkspace::Team::Deltas::TeamSet.new(@base_team_set).process
    end

    # ### Process
    def process
      ActiveRecord::Base.transaction do
        create_team_set
        create_teams
        activate
        assign_team_set_for_assignments(@new_team_set)
        reconcile
      end
      @new_team_set
    end

    private

    # ### Helpers
    def team_class;     Thinkspace::Team::Team;    end
    def team_set_class; Thinkspace::Team::TeamSet; end
    def user_class;     Thinkspace::Common::User;  end

    def get_assignments; @space.thinkspace_casespace_assignments.scope_upcoming; end # current or upcoming assignments
    def assign_team_set_for_assignments(team_set); get_assignments.each { |assignment| team_set.assign_to_record(assignment) }; end

    # Creates the new team_set
    def create_team_set; @new_team_set = team_set_class.create(title: @options[:title]); end

    # Creates teams for the new team_set, based on the transform
    def create_teams
      @transform['teams'].each do |tobj|
        team = team_class.create(title: tobj['title'], color: tobj['color'], team_set_id: @new_team_set.id, authable: @space)
        team.thinkspace_common_users << user_class.where(id: tobj['user_ids'])
        delta_team = @delta[:teams].find { |t| t[:id] == tobj['id']}
        delta_team[:new_id] = team.id
      end
    end

    # Activates the new team_set, deactivates the old team_set and resets the transform
    def activate
      @new_team_set.scaffold   = @transform.deep_dup
      @base_team_set.transform = {}
      @base_team_set.undefault!
      @new_team_set.make_default!
    end

    # Reconciles the old team_set with the changes
    def reconcile
      @base_team_set.reconcile(@delta)
    end

  end
end; end; end