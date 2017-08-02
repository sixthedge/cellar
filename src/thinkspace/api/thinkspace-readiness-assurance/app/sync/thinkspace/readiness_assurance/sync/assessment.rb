module Thinkspace; module ReadinessAssurance; module Sync; class Assessment
  attr_accessor :options
  attr_accessor :assessment
  attr_accessor :phase

  def initialize(options, assessment)
    @options     = options
    @assessment = assessment
    @phase       = assessment.authable
  end

  def sync
    assignment = @phase.thinkspace_casespace_assignment

    scoring_keys  = ['correct', 'attempted', 'no_answer', 'incorrect_attempt']
    question_keys = ['type', 'random', 'ifat', 'justification']

    if assignment.sync_rat?
      assessments = Thinkspace::ReadinessAssurance::Assessment.where(authable: assignment.thinkspace_casespace_phases).without(@assessment)
      assessments.each do |assessment|
        # assessment = TRAT
        # @assessment = IRAT

        has_transform = @options.dig('transform').present? && @assessment.transform.present?
        ## Check for questions
        assessment.questions = @assessment.questions if @options.dig('questions').present?
        assessment.answers   = @assessment.answers   if @options.dig('answers').present?
        if has_transform
          assessment.transform = generate_default_transform(assessment) unless assessment.transform.present?
          set_nested_value(assessment.transform, 'questions', @assessment.transform['questions'])
          set_nested_value(assessment.transform, 'answers', @assessment.transform['answers'])
        end

        if @options.dig('settings').present?
          if @options.dig('settings', 'next_id').present?
            assessment.settings['next_id'] = @assessment.settings['next_id']
            set_nested_value(assessment.transform, 'settings', 'next_id', @assessment.transform['settings']['next_id']) if has_transform
          end

          if @options.dig('settings', 'scoring').present?
            if @options.dig('settings', 'scoring', 'only').present?
              keys = @options['settings']['scoring']['only']

              keys.each do |key|
                if scoring_keys.include? key
                  assessment.settings['scoring'][key] = @assessment.settings['scoring'][key]
                  set_nested_value(assessment.transform, 'settings', 'scoring', key, @assessment.transform['settings']['scoring'][key]) if has_transform
                end
              end

            elsif @options.dig('settings', 'scoring', 'except').present?
              keys = @options['settings']['scoring']['except']

              obj = {}
              keys.each do |key|
                if scoring_keys.include? key
                  obj[key] = assessment.settings['scoring'][key]
                end
              end
              assessment.settings['scoring'] = @assessment.settings['scoring']
              obj.each do |key, value|
                assessment.settings['scoring'][key] = value
              end

            end
          end

          if @options.dig('settings', 'questions').present?
            if @options.dig('settings', 'questions', 'only').present?
              keys = @options.dig('settings', 'questions', 'only')

              keys.each do |key|
                if question_keys.include? key
                  assessment.settings['questions'][key] = @assessment.settings['questions'][key]
                  set_nested_value(assessment.transform, 'settings', 'questions', key, @assessment.transform['settings']['questions'][key]) if has_transform
                end
              end

            elsif @options.dig('settings', 'questions', 'except').present?
              keys = @options.dig('settings', 'questions', 'except')

              obj = {}
              keys.each do |key|
                if question_keys.include? key
                  obj[key] = assessment.settings['questions'][key]
                end
              end

              assessment.settings['questions'] = @assessment.settings['questions']
              obj.each do |key, value|
                assessment.settings['questions'][key] = value
              end
            end
          end
        end
        assessment.save
      end



      ## We care about three columns for sync purposes
      ## => 1. :questions
      ## => 2. :answers
      ## => 3. :settings
      ## questions and answers should always be synced if we're syncing at all
      ## settings is a little more complicated.
      ## certain settings keys should not be modified - ie 'ra_type', others should only be modified conditionally

    end
  end

  def generate_default_transform(assessment)
    {
      settings: assessment.settings
    }
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

end; end; end; end
