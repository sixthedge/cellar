module Thinkspace; module ReadinessAssurance; module ControllerHelpers; module Json

  # ###
  # ### User.
  # ###

  def current_user_json; get_user_json(current_user); end

  def get_user_json(user)
    {id: user.id, first_name: user.first_name, last_name: user.last_name}
  end

  # ###
  # ### Team.
  # ###

  def team_json_with_current_user(phase, teams, options={}); team_json(phase, teams, options.merge(include_current_user: true)); end

  def team_json(phase, teams, options={})
    include_current_user = options[:include_current_user] || false
    set_all_team_users   = options[:set_all_team_users] || false
    data                 = Array.new
    all_users            = Array.new
    Array.wrap(teams).each do |team|
      hash = Hash.new
      hash[:team] = {
        room:  pubsub.room_with_ownerable(phase, team),
        title: team.title,
        id:    team.id,
      }
      users      = team.thinkspace_common_users.scope_active
      all_users += users  if set_all_team_users.present?
      array      = Array.new
      users.each do |user|
        next if !include_current_user && user == current_user
        array.push get_user_json(user)
      end
      hash[:users] = array 
      data.push(hash)
    end
    @all_team_users = all_users.uniq  if set_all_team_users.present?
    data
  end

  def team_json_all_team_users; @all_team_users || Array.new; end

end; end; end; end
