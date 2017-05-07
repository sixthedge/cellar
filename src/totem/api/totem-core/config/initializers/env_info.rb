if ::Rails.env.development? && !::Totem::Settings.config.startup_quiet?

  from_msg = "[info] From (totem-core/config/initializers/env_info.rb)"
  env_msg  = "[info] Rails environment (#{Rails.env})"

  puts ''
  puts from_msg
  puts env_msg
  puts ''

  Rails.logger.info ''
  Rails.logger.info from_msg
  Rails.logger.info env_msg
  Rails.logger.info ''

  keys = ENV.keys.select {|k| k.start_with?('APP') || k.start_with?('RAILS')}.sort
  max  = (keys.map {|k| k.to_s.length}.max || 0) + 2
  vmax = 120
  keys.each do |key|
    val = ENV[key] || ''
    if val.length > vmax
      val = val[0..vmax] + ' more...'
    end
    line = key.to_s.ljust(max, '.') + val.to_s
    puts line
    Rails.logger.info line
  end
  puts ''
  Rails.logger.info ''

end
