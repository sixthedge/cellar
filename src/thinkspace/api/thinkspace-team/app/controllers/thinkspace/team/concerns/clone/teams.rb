module Thinkspace
  module Team
    module Concerns
      module Clone
        module Teams

          def clone_record_teams(record, dictionary, options={})
            space = options[:space] || record.get_space
            raise_clone_exception("Clone teams space not found [record: #{record.inspect}].") if space.blank?
            record.thinkspace_team_teams.each do |team|
              cloned_team          = team.deep_clone include: [], dictionary: dictionary
              cloned_team.title    = 'clone: ' + cloned_team.title  if cloned_team.authable == space
              cloned_team.authable = space
              clone_save_record(cloned_team)
              team.thinkspace_team_team_teamables.each do |teamable|
                next unless teamable.teamable.present?
                cloned_teamable = teamable.deep_clone include: [:teamable, :thinkspace_team_team], dictionary: dictionary
                clone_save_record(cloned_teamable)
              end
              team.thinkspace_team_team_viewers.each do |team_viewer|
                cloned_team_viewer = team_viewer.deep_clone include: [:viewerable, :thinkspace_team_team], dictionary: dictionary
                clone_save_record(cloned_team_viewer)
              end
              unless is_full_clone?(options) # Do not do for assignment/space clones, only phase level.
                team.thinkspace_team_team_users.each do |team_user|
                  cloned_team_user = team_user.deep_clone include: [:thinkspace_team_team], dictionary: dictionary
                  clone_save_record(cloned_team_user)
                end
              end
            end
          end
          
        end
      end
    end
  end
end
