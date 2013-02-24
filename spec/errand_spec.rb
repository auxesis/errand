#!/usr/bin/env ruby

$: <<  File.expand_path(File.join(File.dirname(__FILE__), '..'))
require 'lib/errand'
require 'tmpdir'

describe Errand do

  before(:all) do
    @tmpdir = Dir.mktmpdir
  end

  before(:each) do
    @rrd = Errand.new(:filename => File.join(@tmpdir, 'test.rrd'))
  end

  it "should create data" do

    @rrd.create(:start => Time.now.to_i - 1, :step => 300,
                :sources => [
                  {:name => "Counter", :type => :counter, :heartbeat => 1800, :min => 0, :max => 4294967295},
                  {:name => "Total", :type => :derive, :heartbeat => 1800, :min => 0, :max => 'U'} ],
                :archives => [
                  {:function => :average, :xff => 0.5, :steps => 1, :rows => 2400}]).should be_true

    sources = @rrd.info.keys.grep(/^ds\[/).map { |ds| ds[3..-1].split(']').first}.uniq
    sources.size.should == 2

  end

  it "should dump data" do
    @rrd.create(:start => Time.now.to_i - 1, :step => 300,
                :sources => [
                  {:name => "Counter", :type => :counter, :heartbeat => 1800, :min => 0, :max => 4294967295},
                  {:name => "Total", :type => :derive, :heartbeat => 1800, :min => 0, :max => 'U'} ],
                :archives => [
                  {:function => :average, :xff => 0.5, :steps => 1, :rows => 2400}]).should be_true

    tmpfile = File.join(@tmpdir, 'test.out')
    lambda {
      @rrd.dump(:filename => tmpfile)
      @rrd.dump # <= no args
    }.should_not raise_error
  end

  it "should update rrds" do
    @rrd.create(:start => Time.now.to_i - 1, :step => 1,
                :sources => [
                  {:name => "Sum", :type => :gauge, :heartbeat => 1800, :min => 0, :max => 4294967295},
                  {:name => "Total", :type => :gauge, :heartbeat => 1800, :min => 0, :max => 'U'} ],
                :archives => [
                  {:function => :average, :xff => 0.5, :steps => 1, :rows => 2400}]).should be_true

    @rrd.update(:sources => [
                  {:name => "Sum", :value => 1},
                  {:name => "Total", :value => 30}]).should be_true

    @rrd.fetch[:data].each_pair do |source, values|
      values.compact.size.should > 0
    end
  end

  it "should update with weird data" do
    time = Time.now.to_i - 300
    @rrd.create(:start => time - 1, :step => 1,
                :sources => [
                  {:name => "Sum", :type => :gauge, :heartbeat => 1800, :min => 0, :max => 4294967295},
                  {:name => "Total", :type => :gauge, :heartbeat => 1800, :min => 0, :max => 'U'} ],
                :archives => [
                  {:function => :average, :xff => 0.5, :steps => 1, :rows => 2400}]).should be_true

    updates = []
    100.times do |i|
      updates << {:name => "Sum", :time => time + i , :value => 1}
      updates << {:name => "Total", :time => time + i * 4, :value => 30}
    end

    @rrd.update(:sources => updates)

    @rrd.fetch[:data].each_pair do |source, values|
      values.compact.size.should > 0
    end
  end

  it "should fetch data" do
    time = Time.now.to_i - 300
    @rrd.create(:start => time - 1, :step => 1,
                :sources => [
                  {:name => "Sum", :type => :gauge, :heartbeat => 1800, :min => 0, :max => 4294967295},
                  {:name => "Total", :type => :gauge, :heartbeat => 1800, :min => 0, :max => 'U'} ],
                :archives => [
                  {:function => :average, :xff => 0.5, :steps => 1, :rows => 2400}]).should be_true

    100.times do |i|
      @rrd.update(:sources => [
                    {:name => "Sum", :time => time + i, :value => 1},
                    {:name => "Total", :time => time + i, :value => 30}]).should be_true
    end

    @rrd.fetch[:data].each_pair do |source, values|
      values.compact.size.should > 0
    end
  end

  it "should return timestamp of first value"
  it "should return timestamp of last value"

end
