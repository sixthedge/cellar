module Thinkspace; module Team; module Exploders
  class TeamSet

    attr_reader :team_set, :options, :transform, :team_set_teams, :team_set_teams_by_id, :transform_teams, :space

    # ### Initialization
    def initialize(team_set, options={})
      @team_set             = team_set
      @options              = options
      @transform            = options[:transform] || @team_set.transform
      @team_set_teams       = @team_set.thinkspace_team_teams
      @team_set_teams_by_id = @team_set_teams.index_by(&:id)
      @transform_teams      = @transform['teams']
      @space                = team_set.get_space
      process
    end


    # ### Helpers
    def get_transform_team_ids;       @transform_teams.map { |t| t['id'] };                                  end
    def get_new_transform_teams;      @transform_teams.select { |t| t['new'] == true };                      end
    def get_existing_transform_teams; @transform_teams.select { |t| !t.has_key?('id') || t['id'] == false }; end

    def get_team_set_team_ids; @team_set_teams_by_id.keys;      end
    def get_team_set_team_by_id(id); @team_set_teams_by_id[id]; end

    def team_class; Thinkspace::Team::Team; end


    # ### Process
    def process
      ActiveRecord::Base.transaction do
        process_deleted
        process_new
        process_existing
        save
      end
    end

    def process_deleted
      ids = get_team_set_team_ids - get_transform_team_ids
      team_class.where(id: ids).destroy_all
    end

    def process_new
      get_new_transform_teams.each do |tobj|
        record = Thinkspace::Team::Team.create(title: tobj['title'], color: tobj['color'], team_set_id: @team_set.id, authable: @space)
        record.thinkspace_common_users << Thinkspace::Common::User.where(id: tobj['user_ids'])
        tobj['id'] = record.id
        tobj.delete('new')
      end
    end

    def process_existing
      get_existing_transform_teams.each do |tobj|
        record       = get_team_set_team_by_id(tobj['id'])
        record.title = tobj['title']
        record.thinkspace_team_team_users.destroy_all
        record.thinkspace_common_users << Thinkspace::Common::User.where(id: tobj['user_ids'])
        record.save
      end
    end

    def save
      @team_set.scaffold  = @transform.deep_dup
      @team_set.transform = {}
      @team_set.save
    end

















    def explode




            ActiveRecord::Base.transaction do 
              transform      = @team_set.transform
              trans_team_ids = transform['teams'].map { |t| t['id'] }
              cur_team_ids   = @team_set.thinkspace_team_teams.pluck(:id)

              ## Delete excluded teams
              deleted_team_ids = cur_team_ids - trans_team_ids
              Thinkspace::Team::Team.where(id: deleted_team_ids).destroy_all

              new_teams = transform['teams'].select { |t| t.has_key?('new') }
              existing_teams = transform['teams'].select { |t| !t.has_key?('new') }

              new_teams.each do |team|
                new_team = Thinkspace::Team::Team.create(title: team['title'], color: team['color'], team_set_id: @team_set.id, authable: @team_set.thinkspace_common_space)
                new_team.thinkspace_common_users << Thinkspace::Common::User.where(id: team['user_ids'])
                team['id']  = new_team.id
                team.delete('new')
              end

              existing_teams.each do |team|
                record = Thinkspace::Team::Team.find(team['id'])
                record.title = team['title']
                record.thinkspace_team_team_users.destroy_all
                record.thinkspace_common_users << Thinkspace::Common::User.where(id: team['user_ids'])
                record.save
              end

              @team_set.scaffold  = @team_set.transform.deep_dup
              @team_set.transform = nil

              controller_save_record(@team_set)
            end
    end


  end
end; end; end