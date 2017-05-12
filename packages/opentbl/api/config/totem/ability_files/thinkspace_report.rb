module Thinkspace; module Authorization
class ThinkspaceReport < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def reports
    r = get_class 'Thinkspace::Report::Report'
    return if r.blank?
    report = Thinkspace::Report::Report
    file   = Thinkspace::Report::File
    can [:access, :read, :destroy], report, thinkspace_common_user: current_user
    can [:generate], report
    can [:read], file, thinkspace_report_report: {user_id: current_user.id}
  end

end; end; end
