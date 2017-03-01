module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Score; module Base

  def rescore?;   processor.action_options[:rescore] == true; end
  def ifat_only?; processor.action_options[:ifat_only] == true; end

  def correct?(qid);  correct_answer(qid) == response_answer(qid); end
  def answered?(qid); !response_answer(qid).nil?; end
  def ifat?(qid);     question_questions(qid)[:ifat] == true; end

  def response_answer(qid);    response_answers[qid]; end
  def correct_answer(qid);     correct_answers[qid]; end
  def question_scoring(qid);   question_setting(qid)[:scoring] || Hash.new; end
  def question_questions(qid); question_setting(qid)[:questions] || Hash.new; end
  def question_setting(qid);   question_settings[qid] || Hash.new; end

  def score_no_answer(qid);   question_scoring(qid)[:no_answer] || 0; end
  def score_attempted(qid);   question_scoring(qid)[:attempted] || 0; end
  def score_correct(qid);     question_scoring(qid)[:correct]   || 1; end
  def incorrect_attempt(qid); question_scoring(qid)[:incorrect_attempt] || 0; end

  def question_type(qid); question_questions(qid)[:type]; end

  def response_answers;  @response_answers  ||= (response.answers || Hash.new).deep_dup; end
  def correct_answers;   @correct_answers   ||= ((assessment.answers || Hash.new)['correct'] || Hash.new).deep_dup; end
  def question_ids;      question_settings.keys; end

  def question_settings
    @question_settings ||= begin
      hash = Hash.new
      assessment.merged_question_settings_with_scoring.each do |h|
        id = h['id']
        hash[id] = h.with_indifferent_access
      end
      hash
    end
  end

  def number_of_choices(qid); (question_setting(qid)[:choices] || Array.new).length; end

  def questions; Questions.new(self, response); end

  include Helpers::Handler::Records

end; end; end; end; end; end
