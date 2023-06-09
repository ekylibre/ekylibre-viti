$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ekylibre_ekyviti/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ekylibre_ekyviti"
  s.version     = EkylibreEkyviti::VERSION
  s.authors     = ["Thibaut Gorioux"]
  s.email       = ["tgorioux@ekylibre.com"]
  # s.homepage    = "TODO"
  s.summary     = "Ekylibre plugin for viticutlure"
  s.description = "Ekylibre plugin for viticutlure"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc", "Capfile"]
  s.require_path = ['lib']
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '~> 5.2'
  # Encapsulate application's business logic.
  s.add_dependency 'interactor-rails'

  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rails"
end
