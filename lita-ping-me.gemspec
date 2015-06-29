# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "lita-ping-me"
  spec.version       = '0.0.2'
  spec.authors       = ["Douglas Roper"]
  spec.email         = ["dougdroper@gmail.com"]
  spec.summary       = %q{Lita plugin for periodically checking statuses of websites}
  spec.description   = %q{
    periodically checks status of website and alerts chat room if response error
  }
  spec.homepage      = "http://github.com/dougdroper/lita-ping-me"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", "~> 4.0"
  spec.add_runtime_dependency "typhoeus", "~> 0.7"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "rack-test"
end
