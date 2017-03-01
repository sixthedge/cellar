module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Score; class Questions
  # Example response metadata/userdata layout (userdata will include only ifat questions): 
  #       all_correct:        false (metadata only)
  #       number_of_updates:  2              
  #       question_scores:    {ra_1_1: 3, ra_1_2: 2, ra_1_3: 0}
  #       attempt_values:     {ra_1_1: [b, a], ra_1_2: [a, a], ra_1_3: [a, a]}
  #       question_correct:   {ra_1_1: true, ra_1_2: false, ra_1_3: false}
  #       correct_answer:     {ra_1_1: a, ra_1_2: b, ra_1_3: c}

  attr_reader :base, :response
  attr_reader :metadata, :userdata, :current_data
  attr_reader :question_ids

  def initialize(base, response)
    @base           = base
    @response       = response
    @metadata       = (response.metadata || Hash.new).deep_dup.with_indifferent_access
    @userdata       = (response.userdata || Hash.new).deep_dup.with_indifferent_access
    @question_ids   = base.question_ids
    @total_score    = BigDecimal('0')
    @added_attempt  = false
    init_data
  end

  # ###
  # ### Public Methods.
  # ###

  def process
    score_questions
    set_data
    save_response
    response.score
  end

  private

  include Score::MultipleChoice

  # ###
  # ### Save Response.
  # ###

  def save_response
    raise ResponseSaveError, "Response save error validation messages #{response.errors}"  unless response.save
  end

  # ###
  # ### Metadata.
  # ###

  def init_data
    init_hash_data(metadata)
    init_hash_data(userdata)
  end

  def init_hash_data(hash)
    hash[:number_of_updates] ||= 0
    hash[:attempt_values]    ||= Hash.new
    hash[:question_scores]   ||= Hash.new
    hash[:question_correct]    = Hash.new
    hash[:correct_answer]      = Hash.new
  end

  def set_data
    metadata[:all_correct] = all_correct?(metadata) && all_correct?(userdata)
    remove_blank_data(metadata)
    remove_blank_data(userdata)
    response.metadata      = metadata
    response.userdata      = userdata
    response.score         = @total_score
  end

  def remove_blank_data(hash)
    hash.delete(:question_scores)   if hash[:question_scores].blank?
    hash.delete(:question_correct)  if hash[:question_correct].blank?
    hash.delete(:attempt_values)    if hash[:attempt_values].blank?
    hash.delete(:correct_answer)    if hash[:correct_answer].blank?
    hash.delete(:number_of_updates) if hash[:number_of_updates] == 0
  end

  def all_correct?(hash); !hash[:question_correct].values.include?(false); end

  # ###
  # ### Score Questions.
  # ###

  # Currently only implements mutiple choice questions.
  # To add a new question type:
  #  1. Set the value in the assessment.settings[:questions][:type] -or- assessment.questions[i][:questions][:type] (if blank inherits from assessment)
  #  2. Add a 'when' statement and apply the scoring rules (either in this class or include a module)
  #     * scoring should end up calling either correct(qid, score) or incorrect(qid, score)
  def score_questions
    question_ids.each do |qid|
      set_is_ifat_qid(qid)
      next if base.ifat_only? && !ifat_qid?
      @current_data = ifat_qid? ? userdata : metadata
      type          = (base.question_type(qid) || '').to_sym
      case type
      when :multiple_choice   then score_multiple_choice_question(qid)
      else
        raise InvalidQuestionType, "Question type '#{type}' scoring is not implmented."
      end
    end
  end

  # ###
  # ### Add Data Values.
  # ###

  def add_correct(qid, score)
    current_data[:question_correct][qid] = true
    current_data[:correct_answer][qid]   = base.correct_answer(qid)
    add_common(qid, score)
  end

  def add_incorrect(qid, score)
    current_data[:question_correct][qid] = false
    add_common(qid, score)
  end

  def add_common(qid, score)
    if rescore?
      add_score(qid, score)
    else
      add_attempt
      add_score(qid, score)
      add_question_attempt_value(qid)
    end
  end

  def add_attempt
    return if @added_attempt
    current_data[:number_of_updates] += 1
    @added_attempt = true
  end

  def add_score(qid, score)
    @total_score += score
    current_data[:question_scores][qid] = score
  end

  def add_question_attempt_value(qid)
    return unless base.answered?(qid)
    answer = base.response_answer(qid) || ''
    array  = (current_data[:attempt_values][qid] ||= Array.new)
    array.push(answer) unless array.last == answer
  end

  # ###
  # ### Helpers.
  # ###

  def set_is_ifat_qid(qid); @ifat_qid = base.ifat?(qid); end
  def ifat_qid?;            @ifat_qid == true; end

  def rescore?; base.rescore?; end

  class ResponseSaveError   < StandardError; end
  class InvalidQuestionType < StandardError; end

end; end; end; end; end; end
