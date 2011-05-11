#!/usr/bin/env ruby

require 'rubygems'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "errand"
    gemspec.summary = "Ruby language binding for RRD tool version 1.2+"
    gemspec.description = "Errand provides Ruby bindings for RRD functions (via librrd), and a concise DSL for interacting with RRDs."
    gemspec.email = "lindsay@holmwood.id.au"
    gemspec.homepage = "http://auxesis.github.com/errand"
    gemspec.authors = ["Lindsay Holmwood"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

begin
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ["--options", "spec/spec.opts"]
  end
rescue LoadError
  puts "RSpec not available. Install it with: gem install rspec"
end

