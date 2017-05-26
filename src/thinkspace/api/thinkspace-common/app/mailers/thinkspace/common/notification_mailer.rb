module Thinkspace
  module Common
    class NotificationMailer < Thinkspace::Common::BaseMailer
      skip_after_action :prevent_delivery, only: [:added_to_space, :invited_to_space, :roster_imported, :space_clone_completed, :space_clone_failed]

      def added_to_space(space_user, inviter)

        @sender = inviter
        @space  = space_user.thinkspace_common_space
        @to     = space_user.thinkspace_common_user
        @url    = spaces_show_url(@space)

        raise "Cannot send an notification without a sender [#{@sender}]." unless @sender.present?
        raise "Cannot send an notification without an email [#{@to}]." unless @to.present?
        raise "Cannot send an notification without a valid space [#{@space}]." unless @space.present?

        subject = "You have been added to #{@space.title}"
        mail(to: @to.email, subject: format_subject(subject))
      end

      def invited_to_space(space_user, inviter)
        @sender     = inviter
        @space      = space_user.thinkspace_common_space
        @to         = space_user.thinkspace_common_user
        @expires_in = (@to.activation_expires_at.to_datetime - DateTime.now).to_i + 1 # Add back in 'today'
        token       = @to.activation_token
        @url        = users_signup_url(token,@to.email,@space)

        raise "Cannot send an notification without a sender [#{@sender}]." unless @sender.present?
        raise "Cannot send an notification without an email [#{@to}]." unless @to.present?
        raise "Cannot send an notification without a valid space [#{@space}]." unless @space.present?

        subject = "Invitation to #{@space.title}"
        mail(to: @to.email, subject: format_subject(subject))
      end

      def roster_imported(sender, status, space)
        @to      = sender
        @status  = status
        @success = status.blank?
        @space   = space
        @url     = teams_roster_url(space)

        raise "Cannot send an notification without an email [#{@to}]." unless @to.present?
        raise "Cannot send an notification without a valid space [#{@space}]." unless @space.present?

        subject = 'Roster Imported'
        mail(to: @to.email, subject: format_subject(subject))
      end

      # def space_clone_completed(user, original_space, cloned_space)
      #   @user           = user
      #   @original_space = original_space
      #   @cloned_space   = cloned_space

      #   url_suffix    = "/spaces/#{cloned_space.id}"
      #   @host         = 'http://localhost:4200' if Rails.env.development?
      #   @host         = Rails.application.secrets.smtp['postmark']['domain'] if Rails.env.production?
      #   @url          = @host + url_suffix
      #   subject       = "#{original_space.title} has been successfully cloned."
      #   mail_settings = { to: @user.email, subject: format_subject(subject) }
      #   mail(mail_settings)
      # end

      # def space_clone_failed(user, original_space)
      #   @user           = user
      #   @original_space = original_space

      #   subject       = "#{original_space.title} could not be cloned."
      #   mail_settings = { to: @user.email, subject: format_subject(subject) }
      #   mail(mail_settings)
      # end

      private

      def spaces_show_url(space); format_url("spaces/#{space.id}"); end
      def users_signup_url(token, email, space); format_url("users/sign_up?token=#{CGI.escape(token)}&email=#{CGI.escape(email)}&space=#{CGI.escape(space.title)}"); end
      def teams_roster_url(space); format_url("spaces/#{space.id}/teams/manage"); end

    end
  end
end