module Thinkspace; module ReadinessAssurance; module Deltas
  class Assessment

    # ### Thinkspace::ReadinessAssurance::Deltas::Assessment
    # ----------------------------------------
    # The purpose of this object is to generate a hash that describes the difference between an assessment's 
    # question, answers, and settings columns and a transform

    attr_reader :assessment, :options, :phase, :assignment, :transform, :questions_by_id, :transform_questions_by_id, :delta

    # ### Initialization
    def initialize(assessment, options={})
      @assessment                 = assessment
      @options                    = options
      @phase                      = @assessment.authable
      @assignment                 = @phase.thinkspace_casespace_assignment
      @transform                  = @options[:transform] || @assessment.transform
      raise "Attempted to generate delta for assessment #{@assessment.id} with no transform present" unless @transform.present?
      if @transform.present?
        @questions_by_id            = Hash.new; @assessment.questions.each { |q| @questions_by_id[q['id']] = q }
        @transform_questions_by_id  = Hash.new; @transform[questions_key].each { |q| @transform_questions_by_id[q['id']] = q }
      end
      @delta = { questions: [], settings: {}}
    end

    # ### Processing
    def process
      process_questions
      process_settings
      @delta
    end

    def has_changes?
      return true unless @delta[:questions].empty?
      return true if @delta[:settings][:type] == true
      return true if @delta[:settings][:questions] == true
      return true if @delta[:settings][:scoring] == true
      return false
    end

    private

    def process_questions
      get_questions.each do |question| process_question(question) end
      get_new_question_ids.each do |id| add_new_question_delta(id) end
    end

    def process_question(question)
      id         = question['id']
      t_question = get_transform_question_by_id(id)

      return add_deleted_question_delta(id) unless t_question.present?
      return add_dirty_question_delta(id) if get_question_is_dirty(id)
      return add_dirty_question_delta(id) if order_is_strict? && get_question_is_reordered(id)
    end

    def process_settings
      @delta[:settings] = {
        type:      get_settings_type_is_dirty,
        scoring:   hashes_not_equal?(get_settings_scoring, get_transform_settings_scoring),
        questions: hashes_not_equal?(get_settings_questions, get_transform_settings_questions)
      }
    end

    def get_settings_type_is_dirty
      get_settings_type != get_transform_settings_type
    end

    def get_new_question_ids; get_transform_question_ids - get_question_ids; end

    def add_new_question_delta(id);     @delta[:questions] << {id: id, new: true, deleted: false, dirty: false }; end
    def add_deleted_question_delta(id); @delta[:questions] << {id: id, new: false, deleted: true, dirty: false }; end
    def add_dirty_question_delta(id);   @delta[:questions] << {id: id, new: false, deleted: false, dirty: true }; end

    # ### Helpers
    def get_question_is_reordered?(id)
      get_question_index(id) != get_transform_question_index(id)
    end

    def get_question_is_dirty(id)
      original   = get_question_by_id(id)
      t_question = get_transform_question_by_id(id)

      return true if labels_are_strict? && (original['question'] != t_question['question'])
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

    def get_answers; @assessment.answers || Hash.new; end
    def get_transform_answers; @transform[answers_key] || Hash.new; end

    def get_question_index(id)
      question = get_question_by_id(id)
      get_questions.index(question)
    end

    def get_transform_question_index(id)
      question = get_transform_question_by_id(id)
      get_transform_questions.index(question)
    end

    def get_question_by_id(id); @questions_by_id[id]; end
    def get_transform_question_by_id(id); @transform_questions_by_id[id]; end

    def get_question_ids; get_questions.map { |q| q['id'] }; end
    def get_transform_question_ids; get_transform_questions.map { |q| q['id'] }; end

    def get_questions; @assessment.questions; end
    def get_transform_questions; @transform[questions_key]; end

    def get_settings; @assessment.settings; end
    def get_transform_settings; @transform[settings_key]; end

    def get_settings_scoring; get_settings[scoring_key]; end
    def get_transform_settings_scoring; get_transform_settings[scoring_key]; end

    def get_settings_questions; get_settings[questions_key]; end
    def get_transform_settings_questions; get_transform_settings[questions_key]; end

    def get_settings_type; get_settings[type_key]; end
    def get_transform_settings_type; get_transform_settings[type_key]; end

    def order_is_strict?; @options[:questions] && (@options[:questions][:order] == true); end
    def labels_are_strict?; @options[:questions] && (@options[:questions][:label] == true); end

    def hashes_equal?(hash1, hash2)
      return false unless (hash1.keys - hash2.keys).empty?
      return false unless (hash2.keys - hash1.keys).empty?
      hash1.keys.each do |key|
        if hash1[key].is_a?(Hash) && hash2[key].is_a?(Hash)
          return false unless hashes_equal?(hash1[key], hash2[key]) 
        else
          return false unless hash1[key] == hash2[key]
        end
      end
      return true
    end

    def hashes_not_equal?(hash1, hash2); !hashes_equal?(hash1, hash2); end

    # ### Keys
    def questions_key; 'questions'; end
    def answers_key;   'answers';   end
    def settings_key;  'settings';  end
    def correct_key;   'correct';   end
    def type_key;      'ra_type';   end
    def scoring_key;   'scoring';   end

  end
end; end; end