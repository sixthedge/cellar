module Thinkspace
  module Common

    class InvitationMailer < ActionMailer::Base
      include Thinkspace::Common::BaseMailer
      layout 'thinkspace/common/layouts/invitation'
      default from: 'ThinkBot <thinkbot@thinkspace.org>'

      def invitation(invitation)
        @to         = invitation.email
        @token      = invitation.token
        @invitable  = invitation.invitable
        @sender     = Thinkspace::Common::User.find(invitation.sender_id)
        @expires_in = ((invitation.expires_at - DateTime.now).to_i)/86400 # to days

        raise "Cannot send an invitation without an email [#{@to}]." unless @to.present?
        raise "Cannot send an invitation without a valid token [#{@token}]." unless @token.present?
        raise "Cannot send an invitation without a valid invitable [#{@invitable}]." unless @invitable.present?

        url_suffix = "/users/sign_up/?token=#{CGI.escape(@token)}&email=#{CGI.escape(@to)}&invitable=#{CGI.escape(@invitable.title)}"
        @host      = 'http://localhost:4200' if Rails.env.development?
        @host      = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
        @url       = @host + url_suffix
        subject    = "Invitation to #{@invitable.title}"

        mail(to: @to, subject: format_subject(subject))
      end

    end

  end
end