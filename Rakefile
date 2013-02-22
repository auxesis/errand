#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'colorize'
require 'pathname'
$: << Pathname.new(__FILE__).parent.join('lib').expand_path.to_s
require 'errand/version'


desc "build gem"
task :build => :verify do
  build_output = `gem build errand.gemspec`
  puts build_output

  gem_filename = build_output[/File: (.*)/,1]
  pkg_path     = "pkg"
  FileUtils.mkdir_p(pkg_path)
  FileUtils.mv(gem_filename, pkg_path)

  puts "Gem built in #{pkg_path}/#{gem_filename}".green
end

desc "push gem"
task :push do
  filenames = Dir.glob("pkg/*.gem")
  filenames_with_times = filenames.map do |filename|
    [filename, File.mtime(filename)]
  end

  newest = filenames_with_times.sort_by { |tuple| tuple.last }.last
  newest_filename = newest.first

  command = "gem push #{newest_filename}"
  system(command)
end

desc "clean up various generated files"
task :clean do
  [ "webrat.log", "pkg/", "_site/"].each do |filename|
    puts "Removing #{filename}"
    FileUtils.rm_rf(filename)
  end
end

namespace :verify do
  task :changelog do
    changelog_filename = "CHANGELOG.md"
    version = Errand::VERSION

    if not File.exists?(changelog_filename)
      puts "#{changelog_filename} doesn't exist.".red
      exit 1
    end

    if not system("grep ^#{version} #{changelog_filename} >/dev/null 2>&1")
      puts "#{changelog_filename} doesn't have an entry for the version you are about to build.".red
      exit 1
    end
  end

  task :uncommitted do
    uncommitted = `git ls-files -m`.split("\n")
    if uncommitted.size > 0
      puts "The following files are uncommitted:".red
      uncommitted.each do |filename|
        puts " - #{filename}".red
      end
      exit 1
    end
  end

  task :all => [ :changelog, :uncommitted ]
end

task :verify => 'verify:all'

task :default => :features
