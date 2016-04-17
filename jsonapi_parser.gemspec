lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json/api/version'

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi_parser'
  spec.version       = JSON::API::VERSION
  spec.authors       = ['Lucas Hosseini']
  spec.email         = ['lucas.hosseini@gmail.com']
  spec.summary       = 'Parse JSON API documents'
  spec.description   = 'Parser for JSON API documents'
  spec.homepage      = 'https://github.com/beauby/jsonapi_parser'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'json', '~>1.8'
  spec.add_dependency 'activesupport', '~>4.1'

  spec.add_development_dependency 'rspec', '~>3.4'
end
