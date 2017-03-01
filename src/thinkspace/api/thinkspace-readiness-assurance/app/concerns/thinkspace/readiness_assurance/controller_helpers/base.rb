module Thinkspace; module ReadinessAssurance; module ControllerHelpers; module Base
  extend ::ActiveSupport::Concern
  included do

    # Used when actions that call assessment or response model's 'find_or_create...'.
    rescue_from Assessment::FindOrCreateError, Response::FindOrCreateError do |e|; render_access_denied(e); end

    # Handler errors.
    rescue_from PhaseActions::BaseHandler::HandlerError do |e|; render_access_denied(e); end

    # Note: cannot call 'access_denied' within a rescue_from 'do' block since errors are not propagated.
    def render_access_denied(e)
      error = ::CanCan::AccessDenied.new(e.message, action_name.to_sym, instance_model_var)
      render json: {:errors => cancan_message(error)}, status: 423
    end

    def access_denied(message, user_message='')
      raise_access_denied_exception(message, action_name.to_sym, instance_model_var,  user_message: user_message)
    end

    def instance_model_var
      record_var = '@' + controller_model_class_name.demodulize.underscore
      self.instance_variable_get(record_var)
    end

    def can_update?; @can_update ||= can?(:update, authable); end

  end

  include PhaseActions::Helpers::Handler::Classes

  include Params
  include Json
  include Records

end; end; end; end
