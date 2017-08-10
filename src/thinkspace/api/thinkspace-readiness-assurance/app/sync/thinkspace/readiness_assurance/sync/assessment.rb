module Thinkspace; module ReadinessAssurance; module Sync; class Assessment

  # ### Thinkspace::ReadinessAssurance::Sync::Assessment
  # ----------------------------------------
  #
  # The purpose of this object is to sync questions, answers, and settings from one assessment to 
  # all other assessments in the assignment. Typically this means keeping the iRAT and tRAT data in sync.
  # 
  # Settings need to be synced in a more granular manner as some settings are present only on the tRAT 
  # (i.e. the IFAT settings, # of attempts, attempt score, etc.)
  # - unlock phases
  # - update the assessment's data to the transform
  # - rescore the responses

  attr_accessor :options
  attr_accessor :model
  attr_accessor :phase
  attr_accessor :assignment
  attr_accessor :phases
  attr_accessor :scoring_keys
  attr_accessor :questions_keys
  attr_accessor :default_settings_keys
  attr_accessor :assessment_class
  attr_accessor :assessments

  def initialize(options, assessment)
    @options               = options
    @model                 = model
    @phase                 = @model.authable
    @assignment            = @phase.thinkspace_casespace_assignment
    @phases                = @assignment.thinkspace_casespace_phases
    @scoring_keys          = ['correct', 'attempted', 'no_answer', 'incorrect_attempt']
    @questions_keys        = ['type', 'random', 'ifat', 'justification']
    @default_settings_keys = {scoring: @scoring_keys, questions: @questions_keys}
    @assessment_class      = Thinkspace::ReadinessAssurance::Assessment
    @assessments           = @assessment_class.where(authable: @phases).without(@model)
  end

  def process
    assignment = @phase.thinkspace_casespace_assignment
    return unless assignment.sync_rat?
    process_assessments
  end

  # ### Sync helpers
  def process_assessments
    ActiveRecord::Base.transaction do
      @assessments.each do |assessment|
        process_assessment(assessment)
      end
    end
  end

  def process_assessment(assessment)
    sync_assessment_questions(assessment)
    sync_assessment_answers(assessment)
    sync_assessment_settings(assessment)
    sync_assessment_transform(assessment)
    assessment.save
  end

  def sync_assessment_questions(assessment)
    return unless option_present?('questions')
    assessment.questions = @model.questions
  end

  def sync_assessment_answers(assessment)
    return unless option_present?('answers')
    assessment.answers = @model.answers
  end

  def sync_assessment_settings(assessment)
    return unless option_present?('settings')
    set_settings_value(assessment, 'next_id') if option_present?('settings', 'next_id')
    sync_assessment_settings_subkey(assessment, 'scoring')
    sync_assessment_settings_subkey(assessment, 'questions')
  end

  def sync_assessment_settings_subkey(assessment, subkey, transform=false)
    default_keys = get_default_settings_keys(subkey)
    
    if option_present?('settings', subkey, 'only') # ONLY
      keys = get_option('settings', subkey, 'only')
      keys.each do |key|
        next unless default_keys.include? key
        set_settings_value(assessment, subkey, key) unless transform
        set_transform_value(assessment, 'settings', subkey, key) if transform
      end
    
    elsif option_present?('settings', subkey, 'except') # EXCEPT
      keys = default_keys
      keys.each do |key|
        next if get_option('settings', subkey, 'except').include?(key)
        set_settings_value(assessment, subkey, key) unless transform
        set_transform_value(assessment, 'settings', subkey, key) if transform
      end
    end
  end

  def sync_assessment_transform(assessment)
    return unless sync_transform?

    assessment.transform = generate_default_transform(assessment) unless assessment.transform.present?

    set_transform_value(assessment, 'questions')
    set_transform_value(assessment, 'answers')
    set_transform_value(assessment, 'settings', 'next_id')

    sync_assessment_settings_subkey(assessment, 'scoring', true)
    sync_assessment_settings_subkey(assessment, 'questions', true)
  end

  def generate_default_transform(assessment)
    {
      settings: assessment.settings
    }
  end

  # ### Get/Set Helpers
  def sync_transform?
    @options.dig('transform').present? && @model.transform.present?
  end

  def option_present?(*keys)
    get_option(*keys).present?
  end

  def get_option(*keys)
    @options.dig(*keys)
  end

  def get_default_settings_keys(subkey)
    default_settings_keys[subkey]
  end

  def set_settings_value(assessment, *keys)
    @set_nested_value assessment.settings, *keys, @model.settings.dig(*keys)
  end

  def set_transform_value(assessment, *keys)
    @set_nested_value assessment.transform, *keys, @model.transform.dig(*keys)
  end

  def set_nested_value(hash, *keys, value)
    key = keys.shift
    if keys.empty?
      hash[key] = value
    else
      hash[key] = {} unless (hash[key].is_a?(Hash) && hash[key].present?)
      set_nested_value(hash[key], *keys, value)
    end
  end

  #   assessments.each do |assessment|

  #     has_transform = @options.dig('transform').present? && @assessment.transform.present?
  #     ## Check for questions
  #     assessment.questions = @assessment.questions if @options.dig('questions').present?
  #     assessment.answers   = @assessment.answers   if @options.dig('answers').present?
  #     if has_transform
  #       assessment.transform = generate_default_transform(assessment) unless assessment.transform.present?
  #       set_nested_value(assessment.transform, 'questions', @assessment.transform['questions'])
  #       set_nested_value(assessment.transform, 'answers', @assessment.transform['answers'])
  #     end

  #     if @options.dig('settings').present?
  #       if @options.dig('settings', 'next_id').present?
  #         assessment.settings['next_id'] = @assessment.settings['next_id']
  #         set_nested_value(assessment.transform, 'settings', 'next_id', @assessment.transform['settings']['next_id']) if has_transform
  #       end

  #       if @options.dig('settings', 'scoring').present?
  #         if @options.dig('settings', 'scoring', 'only').present?
  #           keys = @options['settings']['scoring']['only']

  #           keys.each do |key|
  #             if scoring_keys.include? key
  #               assessment.settings['scoring'][key] = @assessment.settings['scoring'][key]
  #               set_nested_value(assessment.transform, 'settings', 'scoring', key, @assessment.transform['settings']['scoring'][key]) if has_transform
  #             end
  #           end

  #         elsif @options.dig('settings', 'scoring', 'except').present?
  #           keys = @options['settings']['scoring']['except']

  #           obj = {}
  #           keys.each do |key|
  #             if scoring_keys.include? key
  #               obj[key] = assessment.settings['scoring'][key]
  #             end
  #           end
  #           assessment.settings['scoring'] = @assessment.settings['scoring']
  #           obj.each do |key, value|
  #             assessment.settings['scoring'][key] = value
  #           end

  #         end
  #       end

  #       if @options.dig('settings', 'questions').present?
  #         if @options.dig('settings', 'questions', 'only').present?
  #           keys = @options.dig('settings', 'questions', 'only')

  #           keys.each do |key|
  #             if question_keys.include? key
  #               assessment.settings['questions'][key] = @assessment.settings['questions'][key]
  #               set_nested_value(assessment.transform, 'settings', 'questions', key, @assessment.transform['settings']['questions'][key]) if has_transform
  #             end
  #           end

  #         elsif @options.dig('settings', 'questions', 'except').present?
  #           keys = @options.dig('settings', 'questions', 'except')

  #           obj = {}
  #           keys.each do |key|
  #             if question_keys.include? key
  #               obj[key] = assessment.settings['questions'][key]
  #             end
  #           end

  #           assessment.settings['questions'] = @assessment.settings['questions']
  #           obj.each do |key, value|
  #             assessment.settings['questions'][key] = value
  #           end
  #         end
  #       end
  #     end
  #     assessment.save
  #   end



  #   ## We care about three columns for sync purposes
  #   ## => 1. :questions
  #   ## => 2. :answers
  #   ## => 3. :settings
  #   ## questions and answers should always be synced if we're syncing at all
  #   ## settings is a little more complicated.
  #   ## certain settings keys should not be modified - ie 'ra_type', others should only be modified conditionally

  # end



end; end; end; end
