# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vidar/version"

Gem::Specification.new do |spec|
  spec.name          = "vidar"
  spec.version       = Vidar::VERSION
  spec.authors       = ["Masataka Pocke Kuwabara"]
  spec.email         = ["kuwabara@pocke.me"]

  spec.summary       = %q{A simple library for CLI tools}
  spec.description   = %q{A simple library for CLI tools}
  spec.homepage      = "https://github.com/pocke/vidar"
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", '~> 5.10.3'
end
