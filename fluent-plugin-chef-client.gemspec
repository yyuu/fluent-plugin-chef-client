# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-chef-client"
  spec.version       = "0.3.2"
  spec.authors       = ["Yamashita Yuu"]
  spec.email         = ["peek824545201@gmail.com"]
  spec.license       = "Apache-2.0"

  spec.summary       = %q{a fluent plugin for chef-client}
  spec.description   = %q{a fluent plugin for chef-client.}
  spec.homepage      = "https://github.com/yyuu/fluent-plugin-chef-client"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "chef", "~> 11.10.4"
  spec.add_dependency "fluentd"
  spec.add_dependency "ohai", "~> 6.20.0"
end
