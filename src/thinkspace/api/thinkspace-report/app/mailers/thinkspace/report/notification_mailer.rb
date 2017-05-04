module Thinkspace; module Report
class NotificationMailer < Thinkspace::Common::BaseMailer
  skip_after_action :prevent_delivery, only: [:report_access_granted, :report_generation_failed]

  def report_access_granted(report_token)
    @report_token = report_token
    @report       = report_token.get_report
    @user         = report_token.get_user
    @token        = report_token.token

    raise "Cannot send an notification without a report_token [#{@report_token}]." unless @report_token.present?
    raise "Cannot send an notification without an user [#{@user}]." unless @user.present?
    raise "Cannot send an notification without an email [#{@user.email}]." unless @user.email.present?
    raise "Cannot send an notification without a valid token [#{@token}]." unless @token.present?

    @url = app_domain + reports_token_url(@report_token)

    subject = 'Your report is ready to download!'
    mail(to: @user.email, subject: format_subject(subject))
  end

  def report_generation_failed(report, error_code, message='Your report failed to generate.')
    @report     = report
    @user       = report.get_user
    @error_code = error_code
    @message    = message
    subject     = 'Your report creation has failed.'
    mail(to: @user.email, subject: format_subject(subject))
  end

  private

  def reports_token_url(report_token); "/reports/#{report_token.token}"; end

end; end; end