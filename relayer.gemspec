# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "relayer/version"

Gem::Specification.new do |s|
  s.name        = "relayer"
  s.version     = Relayer::VERSION
  s.authors     = ["Brian Ewing"]
  s.email       = ["me@brianewing.co.uk"]
  s.homepage    = "http://brianewing.me/pages/relayer"
  s.summary     = "Dead simple, high-performance, event-driven IRC library"
  s.description = "Relayer is a dead simple, high-performance, event-driven IRC library"

  s.rubyforge_project = "relayer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:s
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
