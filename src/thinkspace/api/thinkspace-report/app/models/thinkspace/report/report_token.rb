module Thinkspace; module Report
class ReportToken < ActiveRecord::Base
  has_secure_token :token

  # ###
  # ### Class methods
  # ###
  def self.create_for_report(report)
    report_token = self.create(report_id: report.id, user_id: report.user_id, expires_at: self.get_expires_at)
  end

  def self.get_expires_at; Time.now + 10.days; end

  # ### Scopes
  def self.scope_valid
    where('expires_at > ?', Time.now)
  end

  # ###
  # ### Instance methods
  # ###
  def notify_user
    # Notify the user that the related report is ready.
    Thinkspace::Report::NotificationMailer.report_access_granted(self).deliver_now
  end

  def get_report; thinkspace_report_report; end
  def get_user; thinkspace_common_user; end

  def is_valid?; self.expires_at > Time.now; end

  totem_associations
end; end; end