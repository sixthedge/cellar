module Totem; module Cli; module HelpersEmber; module Versions

  # ###
  # ### Set ember-cli, node and npm versions.
  # ###

  attr_reader :installed_ember_cli_version
  attr_reader :installed_node_version
  attr_reader :installed_npm_version
  attr_reader :ember_cli_is_installed
  attr_reader :node_is_installed
  attr_reader :npm_is_installed

  def set_run_versions
    @installed_ember_cli_version = 'not installed'
    @installed_node_version      = 'not installed'
    @installed_npm_version       = 'not installed'

    version = `ember --version` rescue version = nil
    @ember_cli_is_installed = false
    if version.present? && (match = version.match /ember-cli:(.*?)\n/)
      @installed_ember_cli_version = match[1].to_s.strip
      @ember_cli_is_installed      = true
    end

    version = `node --version` rescue version = nil
    if version.blank?
      @node_is_installed = false
    else
      @node_is_installed = true
      @installed_node_version = version.each_line.first.strip.sub(/^v/, '')
    end

    version = `npm --version` rescue version = nil
    if version.blank?
      @npm_is_installed = false
    else
      @npm_is_installed = true
      @installed_npm_version = version.each_line.first.strip
    end

  end

  # NPM version 3 flattens the node_modules in an attempt to remove module duplication.
  # Need to base NPM version on the ember-cli version (installs own version of npm) rather than the system NPM.
  # ember-cli 2.10.0 starts using NPM 3.
  def is_npm_version_gte_v3?
    return false if installed_ember_cli_version.blank?
    major = installed_ember_cli_version.split('.').first  || 0
    minor = installed_ember_cli_version.split('.').second || 0
    major.to_i > 1 && minor.to_i > 9
  end

end; end; end; end
