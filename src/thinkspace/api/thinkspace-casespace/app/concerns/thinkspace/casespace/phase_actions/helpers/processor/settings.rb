module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Processor; module Settings

  def set_action_settings(phase=current_phase)
    settings         = get_phase_settings(phase)
    @action_settings = standardize_action_settings(settings)
    debug "Action settings:\n #{action_settings.inspect}\n" if debug?
  end

  def get_phase_settings(phase=current_phase)
    record = phase.settings.present? ? phase : phase.get_configuration
    (record.settings || Hash.new).with_indifferent_access
  end

  private

  def standardize_action_settings(settings)
    settings = convert_action_settings(settings) unless settings.has_key?(:actions) # not in the new structure
    settings = (settings[:actions] || Hash.new)[action] || Hash.new
    settings
  end

  # Provide backward compatibility with old settings structure.
  def convert_action_settings(settings)
    action_keys = settings.keys.select {|k| k.to_s.start_with?('action_')}
    actions     = HashWithIndifferentAccess.new
    action_keys.each do |key|
      event_array = settings[key]
      action      = key.to_s.sub('action_','').sub('_server','')
      action_hash = HashWithIndifferentAccess.new
      [event_array].flatten.compact.each do |hash|
        event      = hash[:event]
        phase_id   = hash[:phase_id]
        next if event.blank?
        case event.to_sym
        when :auto_score
          action_hash[event] = true
        when :complete_phase
          action_hash[:state] = 'completed' # Cannot use event, as complete_phase isn't a valid state.
        when :unlock_phase
          action_hash[:unlock] = phase_id || 'next'
        else
          action_hash[event] = {}
        end
      end
      actions[action] = action_hash
    end
    {actions: actions}
  end

  class SettingsConversionError < StandardError; end

end; end; end; end; end; end
