module Totem; module Core; module Serializers; module SerializerOptions; module Controller

  # ###
  # ### Access Controller Related Values.
  # ###

  def current_user;     controller.send(:current_user); end
  def current_ability;  controller.send(:current_ability); end
  def model_class_name; controller.send(:controller_model_class_name); end
  def params;          (controller.send(:params) || Hash.new); end
  def params_auth;  params[:auth] || Hash.new; end

  def params_id;    params[:id]; end
  def params_ids;   params[:ids]; end

  def params_auth_sub_action;  params_auth[:sub_action]; end
  def params_auth_view_ids;    params_auth[:view_ids]; end
  def params_auth_view_type;   params_auth[:view_type]; end

  # ###
  # ### Access Controller 'totem_action_authorize' Related Values.
  # ###

  def totem_action_authorize
    @totem_action_authorize ||= begin
      if totem_action_authorize?
        taa = controller.send(:totem_action_authorize)
        error "totem_action_authorize is blank.  Have you called 'totem_action_authorize!' before 'totem_action_serializer_options'?."  if taa.blank?
        taa
      else
        error "totem_action_authorize is not implemented for this controller."
      end
    end
  end

  def totem_action_authorize?; controller.instance_variable_get(:@totem_action_authorize).present?; end

  def authable_ability;  totem_action_authorize.authable_ability; end
  def ownerable_ability; totem_action_authorize.ownerable_ability; end
  def sub_action;        totem_action_authorize.sub_action; end
  def params_ownerable;  totem_action_authorize.params_ownerable; end
  def record_ownerable;  totem_action_authorize.record_ownerable; end
  def params_authable;   totem_action_authorize.params_authable; end
  def record_authable;   totem_action_authorize.record_authable; end

end; end; end; end; end
