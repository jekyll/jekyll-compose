# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/compose/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-compose"
  spec.version       = Jekyll::Compose::VERSION
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = %q{Streamline your writing in Jekyll with these commands.}
  spec.description   = %q{Streamline your writing in Jekyll with these commands.}
  spec.homepage      = "https://github.com/jekyll/jekyll-compose"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
