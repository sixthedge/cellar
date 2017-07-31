module Thinkspace
  module ReadinessAssurance
    class Assessment < ActiveRecord::Base
      def question_settings; merged_question_settings; end
      def ra_type; get_ra_type; end
      totem_associations

      # ###
      # ### Class Query Helpers.
      # ###

      def self.authable_irats(authables_scope); find_by_authables(authables_scope, :irat); end
      def self.authable_trats(authables_scope); find_by_authables(authables_scope, :trat); end

      def self.find_by_authables(authables_scope, ra_type)
        ids  = authables_scope.pluck(:id)
        type = authables_scope.klass.name
        self.where("#{table_name}.settings ->> 'ra_type' = '#{ra_type}'").
        where(authable_type: type, authable_id: ids)
      end

      # ###
      # ### Settings.
      # ###

      def sync_assessments
        phase      = self.authable
        assignment = phase.thinkspace_casespace_assignment

        if assignment.sync_rat?
          assessments = Thinkspace::ReadinessAssurance::Assessment.where(authable: assignment.thinkspace_casespace_phases).without(self)
          assessments.each do |assessment|
            assessment.update_columns(questions: self.questions, answers: self.answers, settings: self.settings.deep_merge(assessment.settings))
          end
        end
      end

      def self.assignment_has_responses?(assignment)
        phases = assignment.thinkspace_casespace_phases
        assessments = self.where(authable: phases)
        assessments.any? { |a| a.has_responses? }
      end

      def get_assignment; authable.thinkspace_casespace_assignment; end

      def sync(options)
        Thinkspace::ReadinessAssurance::Sync::Assessment.new(options, self).sync
      end

      def get_settings; self.settings || Hash.new; end
      def get_ra_type;  get_settings['ra_type']; end

      def irat?; get_ra_type == 'irat'; end
      def trat?; get_ra_type == 'trat'; end

      def ifat?; get_settings.dig('questions', 'ifat') == true; end

      def has_responses?
        Thinkspace::ReadinessAssurance::Response.where(assessment_id: self.id).count > 0
      end

      def default_irat_settings
        {
          ra_type: 'irat',
          next_id: 0,
          questions: {
            type:          'multiple_choice',
            random:        false,
            ifat:          false,
            justification: true
          },
          scoring: {
            correct:           5,
            attempted:         1,
            no_answer:         0,
            incorrect_attempt: -1
          }
        }
      end

      def default_trat_settings
        {
          ra_type: 'trat',
          next_id: 0,
          questions: {
            type:          'multiple_choice',
            random:        false,
            ifat:          false,
            justification: true
          },
          scoring: {
            correct:           5,
            attempted:         1,
            no_answer:         0,
            incorrect_attempt: -1
          }
        }
      end

      # ###
      # ### Question Helpers.
      # ###
      # The question_id may be passed in as an int, but they are stored as string.
      def answer_for_question_id(id); answers.dig('correct', id.to_s); end
      def choices_for_question_id(id)
        question = question_for_id(id)
        return [] unless question.present?
        question['choices']
      end
      def order_for_question_id(id)
        question = question_for_id(id)
        return 0 unless question.present?
        questions.index(question)
      end
      def question_for_id(id); questions.find { |x| x['id'] == id }; end
      def order_for_choice_for_question_id(id, choice)
        choices = choices_for_question_id(id)
        return 0 if choices.empty?
        choice = choices.find { |x| x['id'] == choice }
        return 0 unless choice.present?
        choices.index(choice)
      end
      def label_for_choice_for_question_id(id, choice)
        choices = choices_for_question_id(id)
        return nil if choices.empty?
        choice = choices.find { |x| x['id'] == choice }
        return nil unless choice.present?
        choice['label']
      end
      def question_for_question_id(id)
        question = question_for_id(id)
        return nil unless question.present?
        question['question']
      end

      # Return an array of merged question settings.
      # The settings are a merged copy of the question and assessment settings.
      # This allows settings to be specified at the assessment level or at each question level.
      def merged_question_settings
        assessment_settings = get_settings
        settings_questions  = (assessment_settings['questions'] || Hash.new).deep_dup
        qsettings           = Array.new
        self.questions.each do |question|
          qsettings.push({'questions' => settings_questions}.deep_merge(question))
        end
        qsettings
      end

      def merged_question_settings_with_scoring
        assessment_settings = get_settings
        settings_scoring    = (assessment_settings['scoring'] || Hash.new).deep_dup
        settings_questions  = (assessment_settings['questions'] || Hash.new).deep_dup
        qsettings           = Array.new
        self.questions.each do |question|
          qsettings.push({'scoring' => settings_scoring, 'questions' => settings_questions}.deep_merge(question))
        end
        qsettings
      end

      # ###
      # ### Response and Association Records.
      # ###

      def find_or_create_response_and_association_records(ownerable, options={})
        user          = options[:user]
        create_chat   = options[:create_chat]   != false
        create_status = options[:create_status] != false
        response      = self.find_or_create_response(ownerable, user)
        response.find_or_create_status  if create_status.present?
        response.find_or_create_chat    if create_chat.present?
        response
      end

      def find_or_create_response(ownerable, user=nil)
        raise FindOrCreateError, "Response ownerable is blank."  if ownerable.blank?
        response = self.thinkspace_readiness_assurance_responses.find_by(ownerable: ownerable)
        if response.blank?
          response = self.thinkspace_readiness_assurance_responses.create(
            user_id:        user && user.id,
            ownerable:      ownerable,
            settings:       Hash.new,
            answers:        Hash.new,
            justifications: Hash.new,
            userdata:       Hash.new,
            metadata:       Hash.new,
          )
          raise FindOrCreateError, "Could not find or create response for assessment [errors: #{response.errors.messages}] [ownerable: #{ownerable.class.name.inspect}.#{ownerable.id}]."  if response.errors.present?
        end
        raise FindOrCreateError, "Could not find or create response for assessment [ownerable: #{ownerable.class.name.inspect}.#{ownerable.id}]."  if response.blank?
        response
      end

      class FindOrCreateError < StandardError; end

      # ### 
      # ### Progress Reports
      # ###
      def progress_report; Thinkspace::ReadinessAssurance::ProgressReports::Report.new(self).process; end

      # ###
      # ### Clone Path.
      # ###

      # include ::Totem::Settings.module.thinkspace.deep_clone_helper

      # def cyclone(options={})
      #   self.transaction do
      #     cloned_path = clone_self(options)
      #     clone_save_record(cloned_path)
      #   end
      # end

      # ###
      # ### Delete Ownerable Data.
      # ###

      # include ::Totem::Settings.module.thinkspace.delete_ownerable_data_helper

      # def ownerable_data_associations; [:thinkspace_readiness_assurance_path_items]; end

    end
  end
end
