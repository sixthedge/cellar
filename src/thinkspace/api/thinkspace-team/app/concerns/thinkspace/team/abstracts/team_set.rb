module Thinkspace; module Team; module Abstracts
  class TeamSet < Base

    attr_reader :team_set, :keys, :teams, :space, :results
    attr_writer :assigned, :unassigned

    def initialize(team_set, *keys)
      @team_set = team_set
      @keys     = keys
      @teams    = team_set.thinkspace_team_teams
      @space    = team_set.get_space
      @results  = Hash.new
      process
    end

    def process
      process_users if keys.include?(:users)
      process_teams if keys.include?(:teams)
      @results
    end

    def process_users
      # Writing `assigned` since the `id` value is needed for unassigned the way it is currently written.
      @assigned         = get_assigned
      @unassigned       = get_unassigned
      @results['users'] = @assigned + @unassigned
    end

    def process_teams
      @results['teams'] = get_teams
    end

    # # Querying
    def get_users
      to_pluck = ['id', 'first_name', 'last_name']
      values   = @space.thinkspace_common_users.pluck(*to_pluck)
      pluck_to_hash(values, abstract_keys)
    end

    def get_relational_assigned
      to_pluck = ['thinkspace_common_users.id', 'thinkspace_common_users.first_name', 'thinkspace_common_users.last_name', 'thinkspace_team_teams.id']
      values   = @teams.joins(:thinkspace_common_users).distinct.pluck(*to_pluck)
      pluck_to_hash(values, abstract_keys)
    end

    def get_assigned
      # TODO: Switch to proper model and determine column based on presence of `transform` or not.
      column = 'metadata'
      key    = 'teams'
      table  = 'thinkspace_readiness_assurance_responses'

      query = "SELECT q3.id, q3.team_id, thinkspace_common_users.first_name, thinkspace_common_users.last_name FROM (SELECT q2.team_id AS team_id, (q2.users->>'id')::INTEGER AS id FROM (SELECT (q1.json1->>'id')::INTEGER AS team_id, jsonb_array_elements(q1.json1->'users') AS users FROM (SELECT json1 FROM #{table} t, jsonb_array_elements((t.#{column}->'#{key}')::jsonb) json1) q1) q2) q3 INNER JOIN thinkspace_common_users ON thinkspace_common_users.id = q3.id;"
      @team_set.class.connection.select_all(query).to_hash
    end

    def get_unassigned
      to_pluck = ['id', 'first_name', 'last_name']
      values   = @space.thinkspace_common_users.where.not(id: assigned_ids).distinct.pluck(*to_pluck)
      pluck_to_hash(values, abstract_keys)
    end

    def get_teams
      to_pluck = ['id', 'title']
      values   = @teams.pluck(*to_pluck)
      pluck_to_hash(values, to_pluck)
    end

    # # Helpers
    def abstract_keys; ['id', 'first_name', 'last_name', 'team_id']; end
    def assigned_ids; @assigned.map { |u| u['id'] }.uniq; end

  end
end; end; end