$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'sea_otter/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = 'sea_otter'
  spec.version = SeaOtter::VERSION
  spec.authors = ['Alexandre Zicat']
  spec.email = ['alexzicat@teamhubble.com']
  spec.homepage = 'https://github.com/teamhubble/sea_otter'
  spec.summary = 'Minimal server side setup for running a react app on rails'
  spec.description = 'Minimal server side setup for running a react app on rails'
  spec.license = "MIT"

  spec.files = Dir['{app,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'mini_racer', '~> 0.2.4'
  spec.add_dependency 'rails', '>= 3'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard'
end
