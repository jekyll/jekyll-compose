
# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-compose/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-compose"
  spec.version       = Jekyll::Compose::VERSION
  spec.authors       = ["Parker Moore"]
  spec.email         = ["parkrmoore@gmail.com"]
  spec.summary       = "Streamline your writing in Jekyll with these commands."
  spec.description   = "Streamline your writing in Jekyll with these commands."
  spec.homepage      = "https://github.com/jekyll/jekyll-compose"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r!(bin|lib)/!)
  spec.executables   = spec.files.grep(%r!^bin/!) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.51"
end
