module Thinkspace; module Report
class NotificationMailer < ActionMailer::Base
  include Thinkspace::Common::BaseMailer
  default from: 'ThinkBot <thinkbot@thinkspace.org>'
  layout 'thinkspace/common/layouts/invitation'
  
  def report_access_granted(report_token)
    @report_token = report_token
    @report       = report_token.get_report
    @user         = report_token.get_user
    @token        = report_token.token

    raise "Cannot send an notification without a report_token [#{@report_token}]." unless @report_token.present?
    raise "Cannot send an notification without an user [#{@user}]." unless @user.present?
    raise "Cannot send an notification without an email [#{@user.email}]." unless @user.email.present?
    raise "Cannot send an notification without a valid token [#{@token}]." unless @token.present?

    url_suffix    = "/reports/#{report_token.token}"
    @host         = 'http://localhost:4200' if Rails.env.development?
    @host         = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
    @url          = @host + url_suffix

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

end; end; end