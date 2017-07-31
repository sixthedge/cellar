module Thinkspace; module ReadinessAssurance; module Reconcilers
  class Assignment

    # ### Thinkspace::ReadinessAssurance::Reconcilers::Assignment
    # ----------------------------------------
    #
    # The purpose of this object is to:
    # - generate a delta between the transform and the assessment data
    # - reset response data for each modified question
    # - unlock phases
    # - update the assessment's data to the transform
    # - rescore the responses

    attr_reader :assignment, :options, :phase, :assessment, :transform, :questions_by_id, :transform_questions_by_id, :delta

    # ### Initialization
    def initialize(assignment, options={})
      @assignment                 = assignment
      @options                    = options
      @phase                      = options[:phase]
      @assessment                 = options[:componentable]
      @transform                  = @assessment.transform
      if @transform.present?
        @questions_by_id            = Hash.new; @assessment.questions.each { |q| @questions_by_id[q['id']] = q }
        @transform_questions_by_id  = Hash.new; @transform[questions_key].each { |q| @transform_questions_by_id[q['id']] = q }
        @delta                      = get_delta
      end
    end

    # ### Processing
    def process
      # do we want to duplicate the response and "soft delete" the old so we don't lose student data?
      raise "Attempted to explode assignment #{@assignment.id} with no transform present for assessment #{@assessment.id}" unless @transform.present?

      unless @delta.empty? # just update settings, no need to update responses or unlock the phases
        update_responses 
        unlock_phases
      end
      update_assessment
      rescore_responses
    end

    def update_responses
      get_responses.each do |response|
        @delta.each do |change|
          id = change[:id]
          if change[:new]
            if transform_is_ifat?
              response.userdata[question_scores_key][id] = 0 if response.userdata[question_scores_key].present?
              response.userdata[question_correct_key][id] = false if response.userdata[question_correct_key].present?
            else
              response.metadata[question_scores_key][id] = 0 if response.metadata[question_scores_key].present?
              response.metadata[question_correct_key][id] = false if response.metadata[question_correct_key].present?
            end
          elsif change[:deleted] || change[:dirty]
            response.answers.delete(id) if response.answers.present?
            response.justifications.delete(id) if response.justifications.present?

            if assessment_is_ifat? && transform_is_ifat?
              update_response_data_for_question(response, id, :userdata, :userdata, change[:deleted])
            elsif assessment_is_ifat? && !transform_is_ifat?
              update_response_data_for_question(response, id, :userdata, :metadata, change[:deleted])
            elsif !assessment_is_ifat? && transform_is_ifat?
              update_response_data_for_question(response, id, :metadata, :userdata, change[:deleted])
            else
              update_response_data_for_question(response, id, :metadata, :metadata, change[:deleted])
            end

            response.metadata[all_correct_key] = false
            response.save
          end
        end
      end
    end

    def update_response_data_for_question(response, id, from_key, to_key, deleted)
      data = response.send(from_key).deep_dup.with_indifferent_access

      data[attempt_values_key].delete(id)    if data[attempt_values_key].present?
      data[question_scores_key][id] = 0      if data[question_scores_key].present?
      data[question_scores_key].delete(id)   if data[question_scores_key].present? && deleted
      data[question_correct_key][id] = false if data[question_correct_key].present?
      data[question_correct_key].delete(id)  if data[question_correct_key].present? && deleted
      data[correct_answer_key].delete(id)    if data[correct_answer_key].present?

      response.send "#{to_key}=", data
      response.send "#{from_key}=", {} unless from_key == to_key
    end

    def unlock_phases
      get_phase_states.update_all current_state: 'unlocked'
    end

    def update_assessment
      @assessment.questions = @transform[questions_key]
      @assessment.answers   = @transform[answers_key]

      ## We want to make sure that the assessment has all keys present, not just its defaults
      @assessment.settings = @assessment.settings.deep_merge(@transform[settings_key])

      @assessment.transform = nil
      @assessment.save
    end

    # TODO: Optimize? Currently 5 database transactions per response
    def rescore_responses
      get_responses.each do |response|
        if response.ownerable.is_a?(user_class)
          current_user = response.ownerable
        else
          current_user = response.ownerable.thinkspace_common_users.first
        end
        score             = response.rescore!(current_user)
        response.score    = score
        phase_score       = get_phase_score_for_response(response)
        phase_score.score = score if phase_score.present?
        response.save
        phase_score.save if phase_score.present?
      end
    end

    def get_phase; @phase; end

    private

    # ### Helpers
    def get_phase_states; phase_state_class.where(phase_id: @phase.id).scope_completed; end
    def get_responses; @assessment.thinkspace_readiness_assurance_responses; end

    def get_phase_state_for_user(user); phase_state_class.find_by(ownerable: user, phase_id: @phase.id); end

    def get_phase_score_for_response(response)
      phase_state = get_phase_state_for_user(response.ownerable)
      return nil unless phase_state.present?
      phase_score_class.find_by(user_id: response.ownerable.id, phase_state_id: phase_state.id)
    end

    def assessment_is_ifat?; @assessment.ifat?; end
    def transform_is_ifat?; @transform.dig('settings', 'questions', 'ifat') == true; end

    # Will not generate a delta object for case of a question re-order
    def get_delta
      delta = []
      get_questions.each do |question|
        t_question = get_transform_question_by_id(question['id'])
        if t_question.present?
          delta << {id: question['id'], new: false, deleted: false, dirty: true} if get_question_is_dirty(question['id'])
        else
          delta << {id: question['id'], new: false, deleted: true, dirty: false}
        end
      end
      new_question_ids = get_transform_question_ids - get_question_ids
      new_question_ids.each do |id|
        delta << {id: id, new: true, deleted: false, dirty: false}
      end
      delta
    end

    def get_question_is_dirty(id)
      original   = get_question_by_id(id)
      t_question = get_transform_question_by_id(id)

      return true if original['question'] != t_question['question']
      return true if get_correct_answer_for_question(id) != get_correct_answer_for_transform_question(id)
      return get_question_choices_are_dirty(id)
    end

    def get_question_choices_are_dirty(id)
      original   = get_question_by_id(id)
      t_question = get_transform_question_by_id(id)

      get_choices_for_question(original).each do |choice|
        t_choice = get_choice_for_question(t_question, choice['id'])
        return true unless t_choice.present? # choice was deleted
        return true if t_choice['id'] != choice['id'] # choice id was modified
        return true if t_choice['label'] != choice['label'] # choice label was modified
      end

      get_choices_for_question(t_question).each do |t_choice|
        choice = get_choice_for_question(original, t_choice['id'])
        return true unless choice.present? # choice was added
      end

      return false
    end

    def get_choices_for_question(question); question['choices']; end
    def get_choice_for_question(question, id); get_choices_for_question(question).find { |c| c['id'] == id }; end

    def get_correct_answer_for_question(id); get_correct_answers[id]; end
    def get_correct_answer_for_transform_question(id); get_correct_transform_answers[id]; end

    def get_correct_answers; get_answers[correct_key]; end
    def get_correct_transform_answers; get_transform_answers[correct_key]; end

    def get_answers; @assessment.answers; end
    def get_transform_answers; @transform[answers_key]; end

    def get_question_by_id(id); @questions_by_id[id]; end
    def get_transform_question_by_id(id); @transform_questions_by_id[id]; end

    def get_question_ids; get_questions.map { |q| q['id'] }; end
    def get_transform_question_ids; get_transform_questions.map { |q| q['id'] }; end

    def get_questions; @assessment.questions; end
    def get_transform_questions; @transform[questions_key]; end
    def get_transform_settings; @transform[settings_key]; end

    # ### Keys
    def questions_key; 'questions'; end
    def answers_key;   'answers';   end
    def settings_key;  'settings';  end

    def attempt_values_key;   'attempt_values';   end
    def question_scores_key;  'question_scores';  end
    def question_correct_key; 'question_correct'; end
    def correct_answer_key;   'correct_answer';   end
    def all_correct_key;      'all_correct';      end
    def correct_key;          'correct';          end

    # ### Classes
    def phase_state_class; Thinkspace::Casespace::PhaseState; end
    def phase_score_class; Thinkspace::Casespace::PhaseScore; end
    def user_class;        Thinkspace::Common::User;          end

  end
end; end; end