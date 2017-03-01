# -*- encoding: utf-8 -*-

version = File.read(File.expand_path('../../THINKSPACE_VERSION', __FILE__)).strip

Gem::Specification.new do |s|

  s.name         = 'thinkspace-peer-assessment'
  s.version      = version
  s.authors      = ['Sixth Edge']
  s.email        = ['']
  s.homepage     = 'http://www.thinkspace.org'
  s.summary      = 'ThinkSpace Peer Assessment'
  s.description  = 'The ThinkSpace Peer Assessment engine.'
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['README.md', 'LICENSE.md']
  s.files += Dir['thinkspace-peer-assessment.gemspec']
  s.files += Dir.glob('app/**/*')
  s.files += Dir.glob('config/**/*')
  s.files += Dir.glob('db/**/*')
  s.files += Dir.glob('lib/**/*')

end
