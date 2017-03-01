# -*- encoding: utf-8 -*-

version = File.read(File.expand_path('../../TOTEM_VERSION', __FILE__)).strip

Gem::Specification.new do |s|

  s.name         = 'totem-core'
  s.version      = version
  s.authors      = ['Sixth Edge']
  s.email        = ['']
  s.homepage     = 'http://www.sixthedge.com'
  s.summary      = 'Totem Core'
  s.description  = 'The Totem main configuration engine.'
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['totem-core.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('config/**/*')
  s.files += Dir.glob('db/**/*')
  s.files += Dir.glob('lib/**/*')
  s.files += Dir.glob('test/**/*')

  s.test_files = Dir.glob('test/**/*')

end
