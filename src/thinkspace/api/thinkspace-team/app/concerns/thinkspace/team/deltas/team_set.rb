module Thinkspace; module Team; module Deltas
  class TeamSet

    attr_reader :team_set, :options, :transform, :team_set_teams, :team_set_teams_by_id, :transform_teams, :delta, :delta_teams

    # ### Initialization
    def initialize(team_set, options={})
      @team_set             = team_set
      @options              = options
      @transform            = options[:transform] || @team_set.transform
      raise "Could not create delta for team set with id #{@team_set.id}; no transform provided" unless @transform.present?
      @team_set_teams       = @team_set.thinkspace_team_teams
      @team_set_teams_by_id = @team_set_teams.index_by(&:id)
      @transform_teams      = @transform['teams']
      @delta                = Hash.new
      @delta[:teams]        = Array.new
      @delta[:moves]        = Array.new
      @delta_teams          = @delta[:teams]
      @moves                = @delta[:moves]
    end

    # ### Helpers
    def get_transform_team_ids;          @transform_teams.map    { |t| t['id'] };                                 end
    def get_transform_teams_by_ids(ids); @transform_teams.select { |t| ids.include?(t['id']) };                   end
    def get_new_transform_teams;         @transform_teams.select { |t| t['new'] == true };                        end
    def get_existing_transform_teams;    @transform_teams.select { |t| !t.has_key?('new') || t['new'] == false }; end
    def get_deleted_transform_teams
      ids = get_team_set_team_ids - get_transform_team_ids
      get_transform_teams_by_ids(ids)
    end

    def get_team_set_team_ids; @team_set_teams_by_id.keys;      end
    def get_team_set_team_by_id(id); @team_set_teams_by_id[id]; end

    def get_changed_delta_teams; @delta_teams.select { |t| t[:new] || (!t[:new] && !t[:deleted] && t[:dirty]) }; end

    # ### Process
    def process
      process_deleted
      process_new
      process_existing
      process_moves
      @delta
    end

    def process_deleted
      get_deleted_transform_teams.each do |tobj|
        @delta_teams << {
          id:           tobj['id'],
          additions:    Array.new,
          subtractions: Array.new,
          new:          false,
          deleted:      true,
          dirty:        true
        }
      end
    end

    def process_new
      get_new_transform_teams.each do |tobj|
        @delta_teams << {
          id:           tobj['id'],
          additions:    Array.new,
          subtractions: Array.new,
          total:        Array.new,
          new:          true,
          deleted:      false,
          dirty:        true
        }
      end
    end

    def process_existing
      get_existing_transform_teams.each do |tobj|
        id   = tobj['id']
        team = get_team_set_team_by_id(id)
        @delta_teams << {
          id:           id,
          additions:    tobj['user_ids'] - team.get_user_ids,
          subtractions: team.get_user_ids - tobj['user_ids'],
          original:     team.get_user_ids,
          total:        tobj['user_ids'],
          new:          false,
          deleted:      false,
          dirty:        tobj['user_ids'].uniq.sort != team.get_user_ids.uniq.sort   
        }

      end
    end

    def process_moves
      @delta_teams.each do |tobj|
        tobj[:subtractions].each do |id|
          (@delta_teams - Array.wrap(tobj[:id])).each do |tobj2|
            if tobj2[:additions].include?(id)
              @moves << {
                id:   id,
                from: tobj[:id],
                to:   tobj2[:id]
              }
            end
          end
        end
      end
    end

  end
end; end; end