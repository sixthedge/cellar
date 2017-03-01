module Thinkspace; module ReadinessAssurance; module ControllerHelpers; module Admin

  def server_event_class;        ::Thinkspace::PubSub::ServerEvent; end
  def server_event_record_class; ::Thinkspace::PubSub::ServerEvent::Record; end

  # ###
  # ### Params.
  # ###

  def irat_params;    params[:irat]    || Hash.new; end
  def trat_params;    params[:trat]    || Hash.new; end
  def message_params; params[:message] || Hash.new; end
  def timer_params;   params[:timer]   || Hash.new; end

  # ###
  # ### Space/Assignment.
  # ###

  def validate_space; space; end

  def space
    @admin_space ||= begin
      sp = assignment.get_space
      access_denied "Cannot update space.", sp unless can?(:update, sp)
      sp
    end
  end

  def assignment
    @admin_assignment ||= begin
      a = super
      access_denied "Assignment is blank.", a  if a.blank?
      access_denied "Cannot update assignment.", a  unless can?(:update, a)
      a
    end
  end

end; end; end; end
