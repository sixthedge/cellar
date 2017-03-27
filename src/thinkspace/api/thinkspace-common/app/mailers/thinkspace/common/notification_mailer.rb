module Thinkspace
  module Common
    class NotificationMailer < Thinkspace::Common::BaseMailer
      layout 'thinkspace/common/layouts/invitation'
      skip_after_action :prevent_delivery, only: [:added_to_space, :invited_to_space, :roster_imported, :space_clone_completed, :space_clone_failed]

      def added_to_space(space_user, inviter)

        @sender    = inviter
        @invitable = space_user.thinkspace_common_space
        @user      = space_user.thinkspace_common_user
        @to        = @user.email

        url_suffix = "spaces/#{@invitable.id}"
        @url       = 'http://localhost:4200/' + url_suffix if Rails.env.development?
        @url       = 'https://think.thinkspace.org/' + url_suffix if Rails.env.production?

        raise "Cannot send an notification without a sender [#{@sender}]." unless @sender.present?
        raise "Cannot send an notification without an email [#{@to}]." unless @to.present?
        raise "Cannot send an notification without a valid invitable [#{@invitable}]." unless @invitable.present?

        subject    = "You have been added to #{@invitable.title}"
        mail(to: @to, subject: format_subject(subject))
      end

      def invited_to_space(space_user, inviter)
        @sender     = inviter
        @invitable  = space_user.thinkspace_common_space
        @user       = space_user.thinkspace_common_user
        @to         = @user.email
        @token      = @user.activation_token
        @expires_in = ((@user.activation_expires_at - DateTime.now).to_i)/86400 # to days

        url_suffix = "/users/sign_up/?token=#{CGI.escape(@token)}&email=#{CGI.escape(@to)}&invitable=#{CGI.escape(@invitable.title)}"
        @host      = 'http://localhost:4200' if Rails.env.development?
        @host      = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
        @url       = @host + url_suffix
        subject    = "Invitation to #{@invitable.title}"

        mail(to: @to, subject: format_subject(subject))
      end

      def roster_imported(sender, status, invitable)
        @to        = sender.email
        @status    = status
        @success   = status.blank?
        @invitable = invitable

        url_suffix    = "/casespace/case_manager/spaces/#{invitable.id}/roster"
        @host         = 'http://localhost:4200' if Rails.env.development?
        @host         = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
        @url          = @host + url_suffix
        subject       = 'Roster Imported'
        mail_settings = { to: @to, subject: format_subject(subject) }
        mail(mail_settings)
      end

      def space_clone_completed(user, original_space, cloned_space)
        @user           = user
        @original_space = original_space
        @cloned_space   = cloned_space

        url_suffix    = "/spaces/#{cloned_space.id}"
        @host         = 'http://localhost:4200' if Rails.env.development?
        @host         = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
        @url          = @host + url_suffix
        subject       = "#{original_space.title} has been successfully cloned."
        mail_settings = { to: @user.email, subject: format_subject(subject) }
        mail(mail_settings)
      end

      def space_clone_failed(user, original_space)
        @user           = user
        @original_space = original_space

        subject       = "#{original_space.title} could not be cloned."
        mail_settings = { to: @user.email, subject: format_subject(subject) }
        mail(mail_settings)
      end

    end
  end
end