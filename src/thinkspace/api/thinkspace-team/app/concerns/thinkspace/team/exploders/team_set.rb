module Thinkspace; module Team; module Exploders
  class TeamSet

    attr_reader :base_team_set, :options, :transform, :space, :delta

    # ### Initialization
    def initialize(team_set, options={})
      @base_team_set = team_set
      @transform     = team_set.transform
      @options       = options
      @space         = team_set.get_space
      @delta         = Thinkspace::Team::Deltas::TeamSet.new(@base_team_set).process
    end

    # ### Helpers
    def team_class;     Thinkspace::Team::Team;    end
    def team_set_class; Thinkspace::Team::TeamSet; end
    def user_class;     Thinkspace::Common::User;  end

    def get_assignments; @space.thinkspace_casespace_assignments.scope_upcoming; end # current or upcoming assignments
    def assign_team_set_for_assignments(team_set); get_assignments.each { |assignment| @new_team_set.assign_to_record(assignment) }; end

    # ### Process
    def process
      ActiveRecord::Base.transaction do
        @new_team_set = team_set_class.create(title: @options[:title])
        @transform['teams'].each do |tobj|
          team = team_class.create(title: tobj['title'], color: tobj['color'], team_set_id: @new_team_set.id, authable: @space)
          team.thinkspace_common_users << user_class.where(id: tobj['user_ids'])
          delta_team = @delta[:teams].select { |t| t[:id] == tobj['id']}
          delta_team[:new_id] = team.id
        end
        @new_team_set.scaffold   = @transform.deep_dup
        @base_team_set.transform = {}
        @base_team_set.deactivate!
        @new_team_set.activate!
        assign_team_set_for_assignments(@new_team_set)
        @delta[:new_team_set] = @new_team_set
        @base_team_set.reconcile(@delta)
        @new_team_set
      end
    end




    # # ### Process
    # def process
    #   successful = false
    #   ActiveRecord::Base.transaction do
    #     process_deleted
    #     process_new
    #     process_existing
    #     successful = save
    #   end
    #   successful
    # end

    # def process_deleted
    #   @delta.get_deleted_transform_teams.each do |tobj|
    #     record = @delta.get_team_set_team_by_id(tobj['id'])
    #     record.destroy
    #   end
    # end

    # def process_new
    #   @delta.get_new_transform_teams.each do |tobj|
    #     record = Thinkspace::Team::Team.create(title: tobj['title'], color: tobj['color'], team_set_id: @team_set.id, authable: @space)
    #     record.thinkspace_common_users << Thinkspace::Common::User.where(id: tobj['user_ids'])
    #     tobj['id'] = record.id
    #     tobj.delete('new')
    #   end
    # end

    # def process_existing
    #   @delta.get_existing_transform_teams.each do |tobj|
    #     record       = @delta.get_team_set_team_by_id(tobj['id'])
    #     record.title = tobj['title']
    #     record.thinkspace_team_team_users.destroy_all
    #     record.thinkspace_common_users << Thinkspace::Common::User.where(id: tobj['user_ids'])
    #     record.save
    #   end
    # end

    # def save
    #   @team_set.scaffold  = @transform.deep_dup
    #   @team_set.transform = {}
    #   @team_set.save
    # end

  end
end; end; end