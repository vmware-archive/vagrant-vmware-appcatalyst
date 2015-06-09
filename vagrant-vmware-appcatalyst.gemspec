# encoding: UTF-8
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'vagrant-vmware-appcatalyst/version'

Gem::Specification.new do |s|
  s.name = 'vagrant-vmware-appcatalyst'
  s.version = VagrantPlugins::AppCatalyst::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Fabio Rapposelli']
  s.email = ['fabio@vmware.com']
  s.homepage = 'https://github.com/vmware/vagrant-vmware-appcatalyst'
  s.license = 'Apache License 2.0'
  s.summary = 'VMware AppCatalyst® provider'
  s.description = 'Enables Vagrant to manage machines with VMware AppCatalyst®.'

  s.add_runtime_dependency 'i18n', '~> 0.6'
  s.add_runtime_dependency 'log4r', '~> 1.1'
  s.add_runtime_dependency 'httpclient', '~> 2.6'

  s.add_development_dependency 'rspec-core', '~> 2.14'
  s.add_development_dependency 'rspec-expectations', '~> 2.14'
  s.add_development_dependency 'rspec-mocks', '~> 2.14'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_path = 'lib'
end
