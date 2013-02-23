# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "errand/version"

Gem::Specification.new do |s|
  s.name        = "errand"
  s.version     = Errand::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Lindsay Holmwood" ]
  s.email       = [ "lindsay@holmwood.id.au" ]
  s.homepage    = "https://github.com/auxesis/errand"
  s.summary     = "Ruby language binding for RRD tool version 1.2+"
  s.description = "Errand provides Ruby bindings for RRD functions (via rrd-ffi), and a concise DSL for interacting with RRDs."

  s.rubyforge_project = "errand"

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency     "rrd-ffi",  "= 0.2.13"
  s.add_development_dependency "rake",     ">= 0"
  s.add_development_dependency "rspec",    ">= 0"
  s.add_development_dependency "colorize", ">= 0"
end
