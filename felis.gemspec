# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'felis/version'

Gem::Specification.new do |spec|
  spec.name          = "felis"
  spec.version       = Felis::VERSION
  spec.authors       = ["Dennis Monsewicz"]
  spec.email         = ["dennismonsewicz@gmail.com"]
  spec.description   = %q{A wrapper for Emma API}
  spec.summary       = %q{A wrapper for Emma API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "httparty"
  spec.add_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock", "< 1.16"
end
