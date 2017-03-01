module Thinkspace; module ReadinessAssurance; module PhaseActions
class BaseHandler

  attr_reader :phase, :current_user, :params
  attr_reader :processor, :error_class

  def initialize(phase, current_user, params, processor_options={})
    @phase        = phase
    @current_user = current_user
    @params       = params || Hash.new
    @error_class  = HandlerError
    if processor_options.is_a?(processor_class)
      @processor = processor_options
    else
      @processor = processor_class.new(phase, current_user, processor_options) if phase.present?
    end
    set_timer_params
  end

  # ###
  # ### Score Response.
  # ###

  def score_response(response, ownerable)
    processor.set_action(:submit)
    processor.action_options[:response] = response
    processor.action_score(ownerable)
  end

  # ###
  # ### Helpers.
  # ###

  def handler_error(message); raise HandlerError, message; end

  class HandlerError < StandardError; end

  include Helpers::Handler::Messages
  include Helpers::Handler::Params
  include Helpers::Handler::PhaseStates
  include Helpers::Handler::Records
  include Helpers::Handler::Classes

  include Thinkspace::Casespace::PhaseActions::Helpers::Action::Controller

end; end; end; end
