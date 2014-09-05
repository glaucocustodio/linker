# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linker/version'

Gem::Specification.new do |spec|
  spec.name          = "linker"
  spec.version       = Linker::VERSION
  spec.authors       = ["Glauco Custódio"]
  spec.email         = ["glauco.custodio@gmail.com"]
  spec.summary       = %q{A wrapper to form objects in ActiveRecord. Forget accepts_nested_attributes_for.}
  spec.description   = %q{A wrapper to form objects in ActiveRecord. Forget accepts_nested_attributes_for.}
  spec.homepage      = "https://github.com/glaucocustodio/linker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', ">= 3.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end