module Thinkspace; module PeerAssessment; module Reconcilers
  class Assignment

    # ### Thinkspace::PeerAssessment::Reconcilers::Assignment
    # ----------------------------------------
    #
    # The purpose of this object is to:
    # - generate a delta between the transform and the assessment value
    # - reset review data for all quant data or each modified question
    # - unlock phases
    # - unlock review_sets
    # - update the assessment's value to the transform

    # ### Summary
    # If the type, points, or any quantitative question changes while the assessment is balance points,
    # all quantitative data will be reset for each review. Otherwise, only changed quantitative and 
    # qualitative question data will be reset for each review.

    attr_reader :assignment, :options, :phase, :assessment, :transform, :delta, :team_sets, :review_sets, :reviews

    # ### Initialization
    def initialize(assignment, options={})
      @assignment  = assignment
      @options     = options
      @phase       = options[:phase]
      @assessment  = options[:componentable]
      @transform   = @assessment.transform
      @delta       = get_delta
      @team_sets   = @assessment.thinkspace_peer_assessment_team_sets
      @review_sets = review_set_class.where(team_set_id: @team_sets.pluck(:id))
      @reviews     = review_class.where(review_set_id: @review_sets.pluck(:id))
    end

    # ### Processing
    def process
      raise "Attempted to explode assignment #{@assignment.id} with no transform present for assessment #{@assessment.id}" unless @transform.present?

      unless delta_is_empty?
        options = get_update_options
        update_reviews(options)
        unlock_review_sets
        unlock_phases
      end

      update_assessment
    end

    # 'all' means all question data for that type will be reset
    # 'per' means only changed questions for that type will be reset
    def get_update_options
      options = {
        quantitative: 'per',
        qualitative:  'per'
      }
      options[:quantitative] = 'all' if all_quantitative_data_invalid?
      options
    end

    def update_reviews(options={})
      @reviews.each do |review|
        next unless review.value.present?
        value = review.value.deep_dup
        update_review_data_for_type(value, :quantitative, options)
        update_review_data_for_type(value, :qualitative, options)
        review.value = value
        review.save
      end
    end

    def update_review_data_for_type(value, type, options={})
      if options[type].present?
        if options[type] == 'all' # reset all question data
            value[type.to_s] = Hash.new
        elsif options[type] == 'per' # reset only changed questions
          @delta[type].each do |question|
            if question[:dirty] || question[:deleted]
              value[type.to_s].delete(question[:id].to_s) # why is question ID a string in the review data but an integer in the assessment?
            end
          end
        end
      end
    end

    def unlock_phases
      get_phase_states.update_all current_state: 'unlocked'
    end

    def unlock_review_sets
      get_review_sets.update_all state: 'neutral'
    end

    def update_assessment
      @assessment.value                  = @transform['value']
      @assessment.assessment_template_id = @transform['assessment_template_id']
      @assessment.transform              = nil
      @assessment.save
    end

    def get_delta
      delta = {
        type:         type_is_dirty?,
        points:       points_is_dirty?,
        quantitative: get_question_delta(:quantitative),
        qualitative:  get_question_delta(:qualitative)
      }
    end

    def get_phase; @phase; end

    private

    # ### Helpers
    def all_quantitative_data_invalid?
      return true if @delta[:type] # changed FROM or TO balance points
      return true if @assessment.is_balance? && @delta[:points] # changed points per member or different
      return true if @assessment.is_balance? && @delta[:quantitative].present? # changed at least 1 quant question
      return false
    end

    def delta_is_empty?
      return false if @delta[:type]
      return false if @delta[:points]
      return false if @delta[:quantitative].present?
      return false if @delta[:qualitative].present?
      return true
    end

    def get_phase_states; phase_state_class.where(phase_id: @phase.id).scope_completed; end

    def get_review_sets; @review_sets.scope_submitted; end

    def type_is_dirty?; @assessment.value[options_key][type_key] != @transform['value'][options_key][type_key]; end

    def points_is_dirty?
      points   = @assessment.value[options_key][points_key]
      t_points = @transform['value'][options_key][points_key]
      return false if (points.nil? && t_points.nil?)
      return true unless (points.present? && t_points.present?)
      return !hashes_equal?(points, t_points)
    end

    def question_is_dirty?(type, id)
      question   = get_question(type, id)
      t_question = get_transform_question(type, id)
      return !hashes_equal?(question, t_question)
    end

    def get_question_delta(type)
      delta = []
      get_questions(type).each do |question|
        id         = question['id']
        t_question = get_transform_question(type, id)
        if t_question.present?
          delta << {id: id, new: false, deleted: false, dirty: true} if question_is_dirty?(type, id)
        else
          delta << {id: id, new: false, deleted: true, dirty: false}
        end
      end

      new_questions = get_transform_question_ids(type) - get_question_ids(type)
      new_questions.each do |id|
        delta << {id: id, new: true, deleted: false, dirty: false}
      end

      delta
    end

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

    def get_question(type, id);           get_questions(type).find { |q| q['id'] == id };           end
    def get_transform_question(type, id); get_transform_questions(type).find { |q| q['id'] == id }; end

    def get_question_ids(type);           get_questions(type).map { |q| q['id'] };           end
    def get_transform_question_ids(type); get_transform_questions(type).map { |q| q['id'] }; end

    def get_questions(type);           @assessment.value[type.to_s];   end
    def get_transform_questions(type); @transform['value'][type.to_s]; end

    def type_key;      'type';         end
    def points_key;    'points';       end
    def options_key;   'options';      end
    def questions_key; 'questions';    end
    def quant_key;     'quantitative'; end
    def qual_key;      'qualitative';  end

    def phase_state_class; Thinkspace::Casespace::PhaseState;     end
    def team_set_class;    Thinkspace::PeerAssessment::TeamSet;   end
    def review_set_class;  Thinkspace::PeerAssessment::ReviewSet; end
    def review_class;      Thinkspace::PeerAssessment::Review;    end

  end
end; end; end