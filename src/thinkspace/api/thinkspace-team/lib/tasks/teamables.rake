namespace :thinkspace do
  namespace :teamables do

    task :port, [] => [:environment] do |t, args|
      Thinkspace::Team::Team.transaction do 
        team_teamables = Thinkspace::Team::TeamTeamable.all
        team_teamables.each do |tt|
          team     = tt.thinkspace_team_team
          teamable = tt.teamable
          team_set = team.thinkspace_team_team_set
          unless teamable.present?
            puts "[thinkspace:teamables:port] Skipping due to teamable nil [#{teamable.inspect}] for [#{team.inspect}]"
            next
          end
          if team_set.present?
            create_team_set_teamable(team_set, teamable)
          else
            # create team set, add team to team_set
            authable = team.authable
            raise "Cannot process teamables without an authable [#{team.id}]." unless authable.present?
            space = authable.get_space
            raise "Cannot process teamables without a space [#{team.id}]." unless space.present?
            team_set         = Thinkspace::Team::TeamSet.create(space_id: space.id, title: team.title, user_id: 0)
            team.team_set_id = team_set.id
            team.save
            create_team_set_teamable(team_set, teamable)
          end
        end
      end
    end

    task :fix_space, [] => [:environment] do |t, args|
      Thinkspace::Team::Team.transaction do
        team_set_teamables = Thinkspace::Team::TeamSetTeamble.all
        team_set_teamables.each do |team_set_teamable|
          team_set = team_set_teamable.thinkspace_team_team_set
          teamable = team_set_teamable.teamable
          raise "Cannot process without a team set." unless team_set.present?
          raise "Cannot process without a teamable." unless teamable.present?
          teamable_space = teamable.get_space
          raise "Cannot process without a teamable space." unless teamable_space.present?
          team_set_space = team_set.thinkspace_common_space
          raise "Cannot process without a team_set_space." unless team_set_space.present?
          if teamamble_space != team_set_space
            team_set.space_id = teamable_space.id
            team_set.save
            team_set.thinkspace_team_teams.each do |team|
              team.authable = teamable_space
              team.save
            end
          end
        end
      end

    end

    def create_team_set_teamable(team_set, teamable)
      exists = Thinkspace::Team::TeamSetTeamable.find_by(team_set_id: team_set.id, teamable: teamable)
      return if exists.present?
      puts "[thinkspace:teambles:port] Creating TeamSetTeamable for: team_set_id: [#{team_set.id}] and teamable: [#{teamable.id}]"
      Thinkspace::Team::TeamSetTeamable.create(team_set_id: team_set.id, teamable: teamable)
    end

  end
end