import ember from 'ember'
import fm    from 'totem-config/find_modules'

class TotemListem

  process: ->
    # regex = new RegExp /_config/
    # @list_mods(regex)
    # regex = new RegExp /^thinkspace-space-engine/
    # @list_mods(regex)
    # regex = new RegExp /^thinkspace-user-engine/
    # @list_mods(regex)
    # regex = new RegExp /templates/
    # @list_mods(regex)

  list_mods: (regex) ->
    console.warn 'LISTEM:', regex
    mods  = fm.filter_by(regex)
    for mod in mods
      console.info "  -> MODULE:", mod
    console.log "===>LISTEM done."

export default new TotemListem
