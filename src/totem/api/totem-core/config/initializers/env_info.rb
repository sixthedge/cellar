# Mainly useful for docker containers to verify the Rails environment.

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

if ::Rails.env.development?
  keys = ENV.keys.sort
  max  = keys.map {|k| k.to_s.length}.max + 2
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
