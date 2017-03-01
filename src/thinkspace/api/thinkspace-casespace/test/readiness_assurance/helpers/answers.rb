module Test::ReadinessAssurance::Helpers::Answers
extend ActiveSupport::Concern
included do

  def correct_answers(r=record);     set_answers(r, ra_1_1: :a, ra_1_2: :b, ra_1_3: :c); end
  def incorrect_answers_1(r=record); set_answers(r, ra_1_1: :x, ra_1_2: :b, ra_1_3: :c); end
  def incorrect_answers_2(r=record); set_answers(r, ra_1_1: :x, ra_1_2: :x, ra_1_3: :c); end
  def incorrect_answers_3(r=record); set_answers(r, ra_1_1: :x, ra_1_2: :x, ra_1_3: :x); end

  def answer_1(val, r=record); set_answers(r, (r.answers || Hash.new).merge(ra_1_1: val)); end
  def answer_2(val, r=record); set_answers(r, (r.answers || Hash.new).merge(ra_1_2: val)); end
  def answer_3(val, r=record); set_answers(r, (r.answers || Hash.new).merge(ra_1_3: val)); end

  def correct_1(r=record); answer_1(:a, r); end
  def correct_2(r=record); answer_2(:b, r); end
  def correct_3(r=record); answer_3(:c, r); end

  def incorrect_1(r=record); answer_1(:x, r); end
  def incorrect_2(r=record); answer_2(:y, r); end
  def incorrect_3(r=record); answer_3(:z, r); end

  def set_answers(r, hash); r.answers = hash; save_response(r); end

end; end
