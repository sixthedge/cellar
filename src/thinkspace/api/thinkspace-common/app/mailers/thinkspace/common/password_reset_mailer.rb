module Thinkspace
  module Common
    class PasswordResetMailer < Thinkspace::Common::BaseMailer
      skip_after_action :prevent_delivery, only: [:instructions, :user_not_found]

      def instructions(password_reset)
        token   = password_reset.token
        @email  = password_reset.email
        @url    = password_reset_show_url(token)
        subject = 'Password Reset'

        mail(to: @email, subject: format_subject(subject))
      end

      def user_not_found(email)
        @email              = email
        @user               = Thinkspace::Common::User.find_by(email: email)
        @has_pending_invite = @user.inactive? if @user.present?
        @url                = password_reset_url
        subject             = 'Password Reset'

        mail(to: @email, subject: format_subject(subject))
      end

      private

      def password_reset_show_url(token); format_url("users/password/reset/#{token}"); end
      def password_reset_url; format_url("users/password/reset"); end

    end
  end
end
