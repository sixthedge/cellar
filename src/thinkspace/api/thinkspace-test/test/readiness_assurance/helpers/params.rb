module Test::ReadinessAssurance::Helpers::Params
extend ActiveSupport::Concern
included do

  def get_timer_params(options={})
    settings              = get_let_value(:timer_settings)
    start_at              = get_let_value(:timer_start_at)
    due_at                = get_let_value(:due_at)
    end_at                = get_let_value(:timer_end_at)
    teams                 = options[:trat_teams]  || get_let_value(:trat_teams)  || team_1
    params                = get_params(trat_teams: teams)
    irat                  = params[:irat]
    irat[:due_at]         = due_at   if due_at.present?
    irat[:timer_settings] = settings if settings.present?
    irat[:timer_start_at] = start_at if start_at.present?
    irat[:timer_end_at]   = end_at   if end_at.present?
    params
  end

  def get_irat_to_trat_params(options={})
    idue_at = options[:irat_due_at] || get_let_value(:irat_due_at) || time_now
    teams   = options[:trat_teams]  || get_let_value(:trat_teams)  || team_1
    options[:irat_due_at] = idue_at
    options[:trat_teams]  = teams
    get_params(options)
  end

  def get_params(options={})
    params          = Hash.new
    irat            = params[:irat] = Hash.new
    trat            = params[:trat] = Hash.new
    idue_at         = options[:irat_due_at] || get_let_value(:irat_due_at)
    tdue_at         = options[:trat_due_at] || get_let_value(:trat_due_at)
    teams           = options[:trat_teams]  || get_let_value(:trat_teams)
    irat[:message]  = options[:message]     || default_message
    irat[:due_at]   = idue_at if idue_at.present?
    trat[:due_at]   = tdue_at if tdue_at.present?
    trat[:team_ids] = Array.wrap(teams).map(&:id) if teams.present?
    params
  end

  def params_irat_due_at; params_irat[:due_at]; end
  def params_trat_due_at; params_trat[:due_at]; end

  def params_irat; (params || Hash.new)[:irat] || Hash.new; end
  def params_trat; (params || Hash.new)[:trat] || Hash.new; end

  def default_message; 'test message'; end

end; end
