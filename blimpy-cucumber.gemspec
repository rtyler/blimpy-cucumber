# -*- encoding: utf-8 -*-
require File.expand_path('../lib/blimpy/cucumber/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["R. Tyler Croy"]
  gem.email         = ["tyler@monkeypox.org"]
  gem.description   = "Cucumber steps for testing with Blimpy"
  gem.summary       = "This gem helps spin up and down VMs with Blimpy from within Cucumber tests"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "blimpy-cucumber"
  gem.require_paths = ["lib"]
  gem.version       = Blimpy::Cucumber::VERSION
end
