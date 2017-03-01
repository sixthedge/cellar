module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Handler; module Params

  def release_at;     params[:release_at]; end
  def due_at;         params[:due_at]; end
  def transition_now; params[:transition_now]; end
  def team_ids;       params[:team_ids]; end
  def user_ids;       params[:user_ids]; end
  def message;        params[:message]; end
  def admin_message;  params[:admin_message]; end
  def timer_settings; params[:timer_settings]; end
  def timer_start_at; params[:timer_start_at]; end
  def timer_end_at;   params[:timer_end_at]; end
  def phase_state;    params[:phase_state]; end

  def teams;            processor.get_teams(phase).accessible_by(current_ability, :read).where(id: team_ids); end
  def users;            processor.get_users(phase).accessible_by(current_ability, :read).where(id: user_ids); end
  def team_users(team); processor.get_team_users(team); end

  def timetables(ownerables, all=false)
    processor.timetable(phase, ownerables: ownerables, user: current_user, due_at: due_at, release_at: release_at, all: all)
  end

  # ###
  # ### Timer Params.
  # ###

  def set_timer_params
    case
    when !timer_settings?
    when transition_now?     then params[:due_at] = Time.now.utc
    when due_at.blank?       then handler_error("Timer is present but 'due_at' is blank.")
    else
      params[:timer_settings] = timer_settings.symbolize_keys.reverse_merge(default_timer_settings)
      params[:timer_end_at]   = due_at  if timer_end_at.blank?
    end
  end

  def default_timer_settings
    hash = {user_id: current_user.id, title: assessment.title}
    if timer_once?
      hash.merge(type: :once)
    else
      hash.merge(type: :countdown, unit: :minute, room_event: :timer)
    end
  end

  # ###
  # ### All Params Users in Space with 'user_ids' and 'team_ids'.
  # ###

  def all_params_users
    space = assignment.thinkspace_common_space
    (params_users_in_team_ids(space) + params_users_in_user_ids(space)).uniq
  end

  def params_users_in_team_ids(space)
    return [] if team_ids.blank?
    array         = Array.new
    team_sets_ids = space.thinkspace_team_team_sets.accessible_by(current_ability, :read).pluck(:id)
    all_teams = team_class.where(id: team_ids).where(team_set_id: team_sets_ids)
    all_teams.each do |team|
      array += team.thinkspace_common_users.accessible_by(current_ability, :read).to_ary
    end
    array
  end

  def params_users_in_user_ids(space)
    return [] if user_ids.blank?
    space.thinkspace_common_users.accessible_by(current_ability, :read).where(id: user_ids)
  end

  # ###
  # ### Value Present?
  # ###

  def timetables?; due_at.present? || release_at.present?; end

  def message?;       message.present?; end
  def admin_message?; admin_message.present?; end

  def timer_settings?;  timer_settings.is_a?(::ActionController::Parameters) && timer_settings.present?; end
  def timer_once?;      timer_settings? && (timer_settings[:interval].blank? || timer_start_at.blank?); end
  def transition_now?;  transition_now == true; end

  def all_teams?
    return false if team_ids.blank?
    all_ids    = processor.get_teams(phase).pluck(:id)
    params_ids = team_ids.map {|id| id.to_i}
    unselected = all_ids - params_ids
    unselected.blank?
  end

end; end; end; end; end; end
