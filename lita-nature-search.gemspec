# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "lita-nature-search"
  spec.version       = '0.0.1'
  spec.authors       = ["Douglas Roper"]
  spec.email         = ["dougdroper@gmail.com"]
  spec.summary       = %q{Lita Plugin for searching nature.com}
  spec.description   = %q{
    Search articles form nature.com, also check if nature search is up
  }
  spec.homepage      = "http://github.com/dougdroper/lita-nature-search"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
