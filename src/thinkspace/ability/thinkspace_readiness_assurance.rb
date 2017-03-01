module Thinkspace; module Authorization
class ThinkspaceReadinessAssurance < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def readiness_assurance
    ra = get_class 'Thinkspace::ReadinessAssurance::Assessment'
    return if ra.blank?
    assessment   = Thinkspace::ReadinessAssurance::Assessment
    response     = Thinkspace::ReadinessAssurance::Response
    chat         = Thinkspace::ReadinessAssurance::Chat
    status       = Thinkspace::ReadinessAssurance::Status
    can [:manage], assessment
    can [:manage], response
    can [:manage], chat
    can [:manage], status
  end

end; end; end
