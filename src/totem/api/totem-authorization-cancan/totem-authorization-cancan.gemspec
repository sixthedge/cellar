# -*- encoding: utf-8 -*-

version = File.read(File.expand_path("../../TOTEM_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name         = "totem-authorization-cancan"
  s.version      = version
  s.authors      = ["Sixth Edge"]
  s.email        = [""]
  s.homepage     = "http://www.sixthedge.com"
  s.summary      = "Totem Authorization Cancan"
  s.description  = "The Totem authorization using cancan."
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['totem-authorization-cancan.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('lib/**/*')

  s.add_dependency 'totem', version

end
