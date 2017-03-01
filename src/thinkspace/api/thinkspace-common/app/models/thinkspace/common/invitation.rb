module Thinkspace
  module Common
    class Invitation < ActiveRecord::Base
      totem_associations
      include AASM

      before_create :set_token
      before_create :set_expiry
      after_create  :notify!

      validates :token,     uniqueness: true
      validates :invitable, presence: true
      validates :role,      presence: true#, inclusion: { in: %w( read update owner ) }
      validates :email,     presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create },  uniqueness: { scope: :invitable_id }
      
      aasm column: :state do
        state :neutral, initial: true
        state :sent
        state :accepted
        state :autoaccepted

        event :notify do
          transitions from: :neutral, to: :sent, after: :deliver
        end

        event :accept do
          after do
            accept_all_invitations
          end
          transitions from: :sent, to: :accepted, after: :add_to_invitable
        end

        event :autoaccept do
          transitions from: :sent, to: :autoaccepted, after: :auto_add_to_invitable
        end
      end


      def process
        user = Thinkspace::Common::User.find_by(email: self.email)
        if user.present?
          space_user = Thinkspace::Common::SpaceUser.find_by(user_id: user.id, space_id: self.invitable_id)
          unless space_user.present?
            space_user = Thinkspace::Common::SpaceUser.create(user_id: user.id, space_id: self.invitable_id, role: self.role)
            sender     = Thinkspace::Common::User.find(self.sender_id)
            space_user.notify_added_to_space(sender)
          end
        else
          self.save
        end
      end

      def accept_all_invitations
        invitations = self.class.where(email: email, accepted_at: nil).where.not(id: id)
        invitations.each do |invitation| invitation.set_user_values(self.thinkspace_common_user, true) end
      end

      def add_to_invitable(auto=false)
        klass = invitable_type.safe_constantize
        raise "Cannot call process_invitation on a class that does not exist for: [#{self.inspect}]" unless klass.present?
        if invitable.process_invitation(self, auto)
          self.accepted_at = Time.now
          save
        else
          raise "Did not successfully process the invitation for [#{self.inspect}]."
        end
      end

      def auto_add_to_invitable
        add_to_invitable(true)
      end

      def deliver
        self.sent_at = Time.now
        save
        Thinkspace::Common::InvitationMailer.invitation(self).deliver_now
      end

      def refresh
        set_expiry
        save
      end

      def resend
        refresh
        deliver
      end

      def is_expired?
        expires_at <= Time.now
      end

      def is_accepted?
        accepted_at.present?
      end

      def set_user_values(user, auto=false)
        self.user_id = user.id
        if auto then self.autoaccept else self.accept end
        save
      end

      private

      def set_token
        self.token = SecureRandom.urlsafe_base64(nil, false)
      end

      def set_expiry
        self.expires_at = Time.now + 90.days
      end

    end
  end
end