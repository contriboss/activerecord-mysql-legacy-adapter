# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/mysql/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-mysql-adapter'
  spec.version       = Activerecord::Mysql::Adapter::VERSION
  spec.authors       = ['Abdelkader Boudih']
  spec.email         = ['terminale@gmail.com']

  spec.summary       = 'Deprecated ActiveRecord adapter'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/contriboss/activerecord-mysql-legacy-adapter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_runtime_dependency 'activerecord', '~> 5.0.0.rc1'
  spec.add_runtime_dependency 'mysql', '~> 2.9'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha', '~>1.1.0'
end
