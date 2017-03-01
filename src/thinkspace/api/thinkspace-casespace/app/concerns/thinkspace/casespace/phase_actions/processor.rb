module Thinkspace; module Casespace; module PhaseActions; class Processor

  attr_reader :current_phase, :current_user, :can_update
  attr_reader :action, :action_options, :action_settings
  attr_reader :action_class, :score_class, :lock_class, :unlock_class

  def initialize(phase, current_user, options={})
    @current_phase   = phase
    @current_user    = current_user
    @action          = options[:action]
    @can_update      = options[:can_update] || false
    @debug           = options[:debug]      || false
    @action_options  = options
    @action_settings = Hash.new
    @score_class     = nil
    @action_class    = nil
    @lock_class      = nil
    @unlock_class    = nil
    validate_arguments
    set_action_settings if action.present?
  end

  def validate_arguments
    raise ArgsError, "Phase is blank."  if current_phase.blank?
    raise ArgsError, "Phase must be a phase not '#{current_phase.class.name}'."  unless current_phase.is_a?(phase_class)
    raise ArgsError, "User is blank."   if current_user.blank?
    raise ArgsError, "User must be a user not '#{current_user.class.name}'."  unless current_user.is_a?(user_class)
  end

  # ###
  # ### Setup.
  # ###

  def set_action_class(klass); validate_is_class(klass); @action_class = klass; end
  def set_score_class(klass);  validate_is_class(klass); @score_class  = klass; end
  def set_lock_class(klass);   validate_is_class(klass); @lock_class   = klass; end
  def set_unlock_class(klass); validate_is_class(klass); @unlock_class = klass; end

  def set_action(new_action)
    @action = new_action
    set_action_settings
  end

  include Helpers::Processor::Actions
  include Helpers::Processor::Ownerable
  include Helpers::Processor::Records
  include Helpers::Processor::AutoScore
  include Helpers::Processor::Timetable
  include Helpers::Processor::Settings
  include Helpers::Processor::Debug

  def validate_is_class(klass)
    raise InvalidClassError, "Is not a class: #{klass}." unless klass.is_a?(Class)
  end

  def get_totem_settings_class(name); ::Totem::Settings.classes.thinkspace.get_class(name.to_sym);  end
  def totem_settings_class?(name);    ::Totem::Settings.classes.thinkspace.has_class?(name.to_sym); end

  class ArgsError         < StandardError; end;
  class InvalidClassError < StandardError; end;

end; end; end; end
