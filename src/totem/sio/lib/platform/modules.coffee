class PlatformModules

  fs:      require('fs')
  path:    require('path')

  constructor: (@platform) ->
    @util = @platform.util

  modules: (base_dir, dirs=null) ->
    return [] unless (base_dir and @fs.statSync(base_dir).isDirectory())
    mod_dirs = if @util.is_array(dirs) then dirs else @get_directories(base_dir)
    mods = []
    for dir in mod_dirs
      mod_dir = @path.join base_dir, dir
      files   = @get_files(mod_dir)
      for file in files
        mod_path = @path.join mod_dir, file
        @util.info "platform module:", mod_path
        mod = require(mod_path)
        mods.push(mod)
    mods

  get_files: (dir) -> @fs.readdirSync(dir).filter (file) => @fs.statSync(@path.join(dir,file)).isFile()

  get_directories: (dir) -> @fs.readdirSync(dir).filter (file) => @fs.statSync(@path.join(dir,file)).isDirectory()

  to_string: -> 'PlatformModules'

module.exports = PlatformModules
