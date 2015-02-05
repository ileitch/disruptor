# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'disruptor/version'

Gem::Specification.new do |spec|
  spec.name          = 'disruptor'
  spec.version       = Disruptor::VERSION
  spec.authors       = ['Ian Leitch']
  spec.email         = ['port001@gmail.com']
  spec.summary       = %q(Basic implementation of the LMAX Disruptor pattern in Ruby.)
  spec.homepage      = 'https://github.com/ileitch/disruptor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'concurrent-ruby'

  spec.platform = 'java' if defined? JRUBY_VERSION
end
