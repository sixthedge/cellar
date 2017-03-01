module Thinkspace
  module Common
    class PasswordReset < ActiveRecord::Base

      validates :token, presence: true

      def send_instructions
        Thinkspace::Common::PasswordResetMailer.instructions(self).deliver_now
      end

      def self.notify_user_not_found(email)
        return unless email.present?
        Thinkspace::Common::PasswordResetMailer.user_not_found(email).deliver_now
      end

      totem_associations
    end
  end
end
