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

  # Borne relâchée pour la montée (lot B du plan v6 d'Ekylibre). Le couplage a
  # été mesuré avant : les 9 références à ActiveRecord du plugin sont toutes
  # des API publiques et stables — `Base.transaction`, `RecordNotFound` et un
  # `connection.execute` de SQL PostGIS brut. Rien d'interne.
  s.add_dependency 'rails', '>= 5.2', '< 9'
  # Encapsulate application's business logic.
  s.add_dependency 'interactor-rails'

  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rails"
end
