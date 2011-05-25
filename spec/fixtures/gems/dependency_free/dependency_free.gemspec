# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dependency_free/version"

Gem::Specification.new do |s|
  s.name        = "dependency_free"
  s.version     = DependencyFree::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Example Author"]
  s.email       = ["author@example.com"]
  s.homepage    = ""
  s.summary     = "A gem with no dependencies"
  s.description = "This is an example gem with no dependencies"

  s.rubyforge_project = "dependency_free"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
