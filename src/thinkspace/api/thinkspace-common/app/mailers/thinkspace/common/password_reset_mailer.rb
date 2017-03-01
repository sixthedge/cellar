module Thinkspace
  module Common
    class PasswordResetMailer < ActionMailer::Base
      include Thinkspace::Common::BaseMailer
      layout 'thinkspace/common/layouts/password'
      default from: 'ThinkBot <thinkbot@thinkspace.org>'

      def instructions(password_reset)
        token      = password_reset.token
        @email     = password_reset.email
        url_suffix = "/users/password/reset/#{token}"
        @host      = 'http://localhost:4200' unless Rails.env.production?
        @host      = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
        @url       = @host + url_suffix
        subject    = 'Password Reset'

        mail_settings = { to: @email, subject: format_subject(subject)}
        mail(mail_settings)
      end

      def user_not_found(email)
        @email              = email
        @user               = Thinkspace::Common::User.find_by(email: email)
        @has_pending_invite = @user.inactive? if @user.present?
        url_suffix          = "/users/password/reset"
        @host               = 'http://localhost:4200' if Rails.env.development?
        @host               = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
        @url                = @host + url_suffix
        subject             = 'Password Reset'

        mail_settings = { to: @email, subject: format_subject(subject)}
        mail(mail_settings)
      end


    end
  end
end
