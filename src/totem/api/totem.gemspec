# -*- encoding: utf-8 -*-

version = File.read(File.expand_path('../TOTEM_VERSION', __FILE__)).strip

Gem::Specification.new do |s|

  s.name         = 'totem'
  s.version      = version
  s.authors      = ['Sixth Edge']
  s.email        = ['']
  s.homepage     = 'http://www.sixthedge.com'
  s.summary      = 'Totem Core'
  s.description  = 'The Totem main configuration engine.'
  s.license      = %q{MIT}
  s.require_path = ['lib']

  s.files  = Dir['CODE_OF_CONDUCT.md', 'CONTRIBUTING.md', 'LICENSE.md', 'README.md', 'TOTEM_VERSION', 'totem.gemspec']
  s.files += Dir.glob('vendor/**/*', File::FNM_DOTMATCH)  # include dot (e.g. .gitignore, etc) files in vendor

  s.add_dependency 'totem-core', version

end
