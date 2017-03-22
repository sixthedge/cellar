module Thinkspace; module PeerAssessment
  # # assessment
  # - Type: **Mailer**
  # - Engine: **thinkspace-peer-assessment**
  class AssessmentMailer < ActionMailer::Base
    default from: 'ThinkBot <thinkbot@thinkspace.org>'

    def notify_overview_unlocked(assessment, user)
      @user            = user
      @to              = user.email
      @phase           = assessment.overview_phase
      @assignment      = @phase.thinkspace_casespace_assignment

      raise "Cannot send a notification without an email [#{@to}]." unless @to.present?
      raise "Cannot send a notification without a phase [#{@phase}]." unless @phase.present?
      raise "Cannot send a notification without an assignment [#{@assignment}]." unless @assignment.present?

      # TODO: Figure out a better way to determine host, maybe from config?
      url_suffix = "casespace/cases/#{@assignment.id}/phases/#{@phase.id}?query_id=none"
      @url       = 'http://localhost:4200/' + url_suffix if Rails.env.development?
      @url       = 'https://think.thinkspace.org/' + url_suffix if Rails.env.production?
      subject    = "[ThinkSpace] Peer Evaluation Unlocked for #{@assignment.title}"

      mail(to: @to, subject: subject)
    end

    def notify_review_set_ownerable(review_set, message)
      @message  = message
      @ownerable = review_set.ownerable
      raise "Cannot send a notificatino without an ownerable [#{review_set.id}]" unless @ownerable.present?
      phase      = review_set.get_authable
      raise "Cannot send a notification without a phase [#{phase}]" unless phase.present?
      assignment = phase.thinkspace_casespace_assignment
      raise "Cannot send a notification without an assignment [#{assignment}]" unless assignment.present?
      
      @to = @ownerable.email
      raise "Cannot send a notification without an email [#{@to}]." unless @to.present?
      url_suffix = "casespace/cases/#{assignment.id}/phases/#{phase.id}?query_id=none"
      @url       = 'http://localhost:4200/' + url_suffix if Rails.env.development?
      @url       = 'https://think.thinkspace.org/' + url_suffix if Rails.env.production?
      subject = "[ThinkSpace] Instructor Notification - Peer Evaluation"
      mail(to: @to, subject: subject)
    end

  end
end; end;