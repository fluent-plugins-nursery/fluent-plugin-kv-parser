# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-kv-parser"
  spec.version       = "0.0.2"
  spec.description   = 'Fluentd parser plugin to parse key value pairs'
  spec.authors       = ["kiyoto"]
  spec.email         = ["kiyoto@treasure-data.com"]
  spec.summary       = %q{Fluentd parser plugin to parse key value pairs}
  spec.homepage      = "https://github.com/kiyoto/fluent-plugin-kv-parser"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit", "> 3.0"
  spec.add_runtime_dependency "fluentd", '~> 0.12.0'
end
