# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-chef-client"
  spec.version       = "0.1.0"
  spec.authors       = ["Yamashita Yuu"]
  spec.email         = ["peek824545201@gmail.com"]
  spec.license       = "Apache-2.0"

  spec.summary       = %q{a fluent plugin for chef-client}
  spec.description   = %q{a fluent plugin for chef-client.}
  spec.homepage      = "https://github.com/yyuu/fluent-plugin-chef-client"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "chef", ">= 11.18.0"
  spec.add_dependency "fluentd", ">= 0.10.55"
end
