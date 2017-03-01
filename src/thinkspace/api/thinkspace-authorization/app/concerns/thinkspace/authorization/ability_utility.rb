module Thinkspace; module Authorization; module AbilityUtility

  def get_record_by_model_type_and_model_id_from_params(params)
    get_record_by_model_type_and_model_id(params[:model_type], params[:model_id])
  end

  def get_ownerable_from_params_auth(params)
    auth = params[:auth] || {}
    get_record_by_model_type_and_model_id(auth[:ownerable_type], auth[:ownerable_id])
  end

  def get_authable_from_params_auth(params)
    auth = params[:auth] || {}
    get_record_by_model_type_and_model_id(auth[:authable_type], auth[:authable_id])
  end

  def get_record_by_model_type_and_model_id(model_type, model_id)
    raise_ability_error "Model type is blank"                           if model_type.blank?
    raise_ability_error "Model type #{model_type.inspect} id is blank"  if model_id.blank?
    raise_ability_error "Model type #{model_type.inspect} is not a string"  unless model_type.instance_of?(String)
    model_type  = model_type.gsub('.', '::').classify
    model_class = model_type.safe_constantize
    raise_ability_error "Cannot constantize class #{model_class.inspect}"  if model_class.blank?
    record = model_class.find_by(id: model_id)
    raise_ability_error "Model #{model_type.inspect} [id: #{model_id.inspect}] not found."  if record.blank?
    record
  end

  def raise_ability_error(message='')
    raise AbilityError, message
  end

  def raise_access_denied_exception(message='', action=nil, subject=nil)
    action ||= :unknown
    raise ::CanCan::AccessDenied.new(message, action, subject)
  end

  class AbilityError < StandardError; end

end; end; end
