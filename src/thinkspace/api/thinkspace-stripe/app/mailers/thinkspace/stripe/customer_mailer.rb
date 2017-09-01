module Thinkspace; module Stripe
  class CustomerMailer < Thinkspace::Common::BaseMailer

    def notify_subscription_created(tsc, sub)
      @to         = tsc.ownerable

      raise "Cannot send a notification without an email [#{@to}]." unless @to.present?

      subject = "Welcome to OpenTBL!"
      mail(to: @to.email, subject: format_subject(subject))

      ## Need to make sure that we have plan data to put into the email.
    end

    def notify_subscription_deleted(tsc, sub)
      @to         = tsc.ownerable

      raise "Cannot send a notification without an email [#{@to}]." unless @to.present?

      subject = "OpenTBL Subscription Deleted"
      mail(to: @to.email, subject: format_subject(subject))
    end


  end
end; end;
