module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Score; module MultipleChoice

  def score_multiple_choice_question(qid)
    is_correct = base.correct?(qid)
    score      = ifat_qid? ? score_ifat_multiple_choice(qid, is_correct) : score_multiple_choice(qid, is_correct)
    score      = 0 if score < 0
    is_correct ? add_correct(qid, score) : add_incorrect(qid, score)
  end

  def score_ifat_multiple_choice(qid, is_correct)
    attempts = get_number_of_multiple_choice_attempts(qid)
    case
    when is_correct && attempts == 1  then base.score_correct(qid)   # first answer was correct get full credit
    when !base.answered?(qid)         then base.score_no_answer(qid) # not answered
    when !is_correct                  then base.score_attempted(qid) # answered but incorrect
    else                                                             # correct, but not the first try
      attempts         -= 1 # only use incorrect attempts
      incorrect_attempt = base.incorrect_attempt(qid)
      incorrect_attempt = (incorrect_attempt * -1) if incorrect_attempt >= 0 # incase settings value isn't negative
      score             = base.score_correct(qid) + (incorrect_attempt * attempts)
      attempted_score   = base.score_attempted(qid)
      attempted_score.present? && attempted_score > score ? attempted_score : score
    end
  end

  def score_multiple_choice(qid, is_correct)
    case
    when is_correct          then base.score_correct(qid)
    when base.answered?(qid) then base.score_attempted(qid)
    else                          base.score_no_answer(qid)
    end
  end

  def get_number_of_multiple_choice_attempts(qid)
    array = (current_data[:attempt_values][qid] || Array.new).dup
    array.push base.response_answer(qid)
    array.uniq.length
  end

end; end; end; end; end; end
