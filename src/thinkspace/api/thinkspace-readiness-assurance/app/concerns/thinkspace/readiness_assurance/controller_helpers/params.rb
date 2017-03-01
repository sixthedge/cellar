module Thinkspace; module ReadinessAssurance; module ControllerHelpers; module Params

  def pubsub_question_id_room(qid=question_id, a=authable, o=ownerable); [pubsub_room(a,o), qid].join('/'); end

  def pubsub_room(a=authable, o=ownerable); pubsub.room_with_ownerable(a, o); end

  def totem_action_authorize?; self.send(:totem_action_authorize).present?; end

  def ownerable
    @ownerable ||= begin
      if totem_action_authorize?
        record = totem_action_authorize.params_ownerable
      else
        record = nil
      end
      access_denied "Ownerable is blank."  if record.blank?
      record
    end
  end

  def authable
    @authable ||= begin
      if totem_action_authorize?
        record = totem_action_authorize.record_authable
      else
        record = current_ability.get_authable_from_params_auth(params)
      end
      access_denied "Authable is blank."  if record.blank?
      record
    end
  end

  def question_id
    @question_id ||= begin
      qid = params[:question_id]
      access_denied "Params question id is blank."  if qid.blank?
      access_denied "Asssement is blank."  if @assessment.blank?
      access_denied "Asssement [id: #{@assessment.id}] question [id: #{qid}] is blank."  unless question_id_in_assessment?(qid)
      qid
    end
  end

  def question_id_in_assessment?(question_id)
    questions = @assessment.questions
    access_denied "Asssement [id: #{@assessment.id}] questions are not an array."  unless questions.is_a?(Array)
    questions.find {|q| q['id'] == question_id}
  end

end; end; end; end
