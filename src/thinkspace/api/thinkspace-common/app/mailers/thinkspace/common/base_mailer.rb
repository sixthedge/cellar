module Thinkspace
  module Common
    class BaseMailer < ActionMailer::Base
      include AbstractController::Callbacks
      default from: Rails.application.secrets.mailer['default']['from']
      after_action :prevent_delivery
      layout 'thinkspace/common/layouts/base'
      helper Thinkspace::Common::BaseViewHelper

      private

      def app_domain; Rails.application.secrets.smtp['postmark']['domain']; end
      def prevent_delivery; mail.perform_deliveries = @user.can_email?;     end
      def format_subject(subject); '[OTBL] ' + subject;                     end
        
    end
  end
end