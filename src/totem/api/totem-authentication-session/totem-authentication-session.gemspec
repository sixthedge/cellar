# -*- encoding: utf-8 -*-

version = File.read(File.expand_path("../../TOTEM_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name         = "totem-authentication-session"
  s.version      = version
  s.authors      = ["Sixth Edge"]
  s.email        = [""]
  s.homepage     = "http://www.sixthedge.com"
  s.summary      = "Totem Authentication Session"
  s.description  = "The Totem authentication for sessions."
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['totem-authentication-session.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('config/**/*')
  s.files += Dir.glob('lib/**/*')

  s.add_dependency 'totem', version

end
