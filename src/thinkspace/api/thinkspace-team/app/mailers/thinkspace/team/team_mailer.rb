module Thinkspace
  module Team
    class TeamMailer < Thinkspace::Common::Base
      layout 'thinkspace/team/layouts/notify_team_has_changed'

      def notify_team_has_changed(space_user, inviter)

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

    end
  end
end