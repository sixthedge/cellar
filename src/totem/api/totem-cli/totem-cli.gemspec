# -*- encoding: utf-8 -*-

version = File.read(File.expand_path('../../TOTEM_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name         = 'totem-cli'
  s.version      = version
  s.authors      = ['Sixth Edge']
  s.email        = ['']
  s.homepage     = 'http://www.sixthedge.com'
  s.summary      = 'Totem CLI'
  s.description  = 'The Totem Command Line Interface.'
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.bindir       = 'bin'
  s.executables  = ['totem-app', 'totem-deploy', 'totem-copy', 'totem-ember']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['totem-cli.gemspec']
  s.files += Dir.glob('bin/**/*')
  s.files += Dir.glob('lib/**/*')

end
