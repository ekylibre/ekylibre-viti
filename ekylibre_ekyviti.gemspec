$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ekylibre_ekyviti/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ekylibre_ekyviti"
  s.version     = EkylibreEkyviti::VERSION
  s.authors     = [""]
  s.email       = ["tgorioux@ekylibre.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of EkylibreEkyviti."
  s.description = "TODO: Description of EkylibreEkyviti."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.11.1"

  s.add_development_dependency "pg"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rails"
end
