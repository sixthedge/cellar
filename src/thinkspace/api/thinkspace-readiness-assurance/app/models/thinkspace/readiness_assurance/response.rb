module Thinkspace
  module ReadinessAssurance
    class Response < ActiveRecord::Base
      totem_associations
      has_paper_trail

      def self.scope_by_ownerables(ownerables); where(ownerable: ownerables); end

      def find_or_create_status
        status = self.thinkspace_readiness_assurance_status
        if status.blank?
          status = self.create_thinkspace_readiness_assurance_status(
            settings:  get_status_settings,
            questions: Hash.new,
          )
          raise FindOrCreateError, "Could not find or create status for response [errors: #{status.errors.messages}] [id: #{self.id}]."  if status.errors.present?
        end
        raise FindOrCreateError, "Could not find or create status for response [id: #{self.id}]."  if status.blank?
        status
      end

      def find_or_create_chat
        chat = self.thinkspace_readiness_assurance_chat
        if chat.blank?
          chat = self.create_thinkspace_readiness_assurance_chat(
            messages: Hash.new,
          )
          raise FindOrCreateError, "Could not find or create chat for response [errors: #{chat.errors.messages}] [id: #{self.id}]."  if chat.errors.present?
        end
        raise FindOrCreateError, "Could not find or create chat for response [id: #{self.id}]."  if chat.blank?
        chat
      end

      def get_status_settings
        settings        = Hash.new
        choices         = settings[:choices] = Hash.new
        choices[:order] = get_question_choices_order
        settings
      end

      def get_question_choices_order
        qorder     = Hash.new
        assessment = self.thinkspace_readiness_assurance_assessment
        raise AssessmentNotFoundError, "Assessment for response [id: #{self.id}] not found."  if assessment.blank?
        assessment.question_settings.each do |question|
          question  = question.with_indifferent_access
          qsettings = question[:questions] || Hash.new
          next unless qsettings[:random] == true
          qid = question[:id]
          raise QuestionIdError, "Assessment question #{question.inspect} id is blank."  if qid.blank?
          choices = question[:choices]
          next if choices.blank? || !choices.is_a?(Array)
          qorder[qid] = choices.map {|c| c[:id]}.shuffle
        end
        qorder
      end

      # ###
      # ### Scoring
      # ###
      def rescore!(user)
        raise "Cannot rescore without a valid user." unless user.present?
        authable  = thinkspace_readiness_assurance_assessment.authable
        processor = Thinkspace::Casespace::PhaseActions::Processor.new(authable, user, rescore: true)
        klass     = processor.get_totem_settings_class('ra_auto_score')
        scorer = klass.new(processor, ownerable, Hash.new)
        scorer.process
      end


      class QuestionIdError < StandardError; end
      class AssessmentNotFoundError < StandardError; end
      class FindOrCreateError < StandardError; end

    end
  end
end
