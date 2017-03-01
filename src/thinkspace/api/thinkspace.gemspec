# -*- encoding: utf-8 -*-

version = File.read(File.expand_path("../THINKSPACE_VERSION", __FILE__)).strip

Gem::Specification.new do |s|

  s.name         = "thinkspace"
  s.version      = version
  s.authors      = ["Sixth Edge"]
  s.email        = [""]
  s.homepage     = "http://www.thinkspace.org"
  s.summary      = "ThinkSpace"
  s.description  = "The ThinkSpace educational platform."
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files = Dir['CODE_OF_CONDUCT.md', 'CONTRIBUTING.md', 'LICENSE.md', 'README.md', 'THINKSPACE_VERSION', 'thinkspace.gemspec']

  s.add_dependency 'totem'
  s.add_dependency 'aasm'

end
