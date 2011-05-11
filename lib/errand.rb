#!/usr/bin/env ruby

# Attempt to load the native RRD library provided by the operating system.
require 'rrd'

# Errand:
# Wraps the RRD Ruby library provided by your distribution's package manager,
# exposing a more Ruby-like and accessible interface.

class Errand
  def initialize(opts={})
    raise ArgumentError unless opts[:filename]
    @filename = opts[:filename]
    @backend = ::RRD::Wrapper
  end

  def dump(opts={})
    output = opts[:filename] || ""
    @backend.dump(@filename, output)
  end

  def last
    @backend.last(@filename)
  end

  def fetch(opts={})
    start    = (opts[:start] || Time.now.to_i - 3600).to_s
    finish   = (opts[:finish] || Time.now.to_i).to_s
    function = opts[:function] ? opts[:function].to_s.upcase : "AVERAGE"

    args   = [ @filename, "--start", start, "--end", finish, function ]

    data   = @backend.fetch(*args)
    labels = data.shift
    points = {}

    labels.each_with_index do |label, index|
      points[label] = []
      data.each do |tuple|
        value = tuple[index]
        points[label] << value
      end
    end

    points.delete('time')

    {:start => start, :finish => finish, :data => points}
  end

  def create(opts={})
    step  = (opts[:step] || 300).to_s
    start = (opts[:start] || Time.now.to_i - 10).to_s

    options = ["--step", step, "--start", start]

    sources = opts[:sources].map { |source|
      name      = source[:name]
      type      = source[:type].to_s.upcase
      heartbeat = source[:heartbeat]
      min       = source[:min]
      max       = source[:max]

      ds = ["DS", name, type]
      ds += [heartbeat, min, max] if heartbeat && min && max

      ds.join(':')
    }

    archives = opts[:archives].map { |archive|
      function = archive[:function].to_s.upcase
      xff      = archive[:xff]
      steps    = archive[:steps]
      rows     = archive[:rows]

      rra = ["RRA", function]
      rra += [xff, steps, rows] if xff && steps && rows

      rra.join(':')
    }

    args = options + sources + archives
    @backend.create(@filename, *args) # * "flattens" the array

    true
  end

  def update(opts={})
    time_specified = opts[:sources].find { |source| source[:time] }
    times = opts[:sources].map {|s| s[:time]}.sort.uniq if time_specified

    sources = opts[:sources].map { |source|
      source[:name]
    }.join(':')

    case
    when time_specified && times.size == 1
      values = "#{times.first}:" + opts[:sources].map { |s|
        s[:value]
      }.join(':')

      args = ["--template", sources, values]
      @backend.update(@filename, *args)
    when time_specified && times.size > 1
      times.each do |t|
        points = opts[:sources].find_all { |source| source[:time] == t }

        sources = points.map { |p|
          p[:name]
        }.join(':')

        values = "#{t}:" + points.map { |p|
          p[:value]
        }.join(':')

        args = ["--template", sources, values]
        @backend.update(@filename, *args)
      end

    when !time_specified
      values = "N:" + opts[:sources].map { |source|
        source[:value]
      }.join(':')

      args = ["--template", sources, values]
      @backend.update(@filename, *args)
    end

    true
  end

  def info
    @backend.info(@filename)
  end

  # ordered array of data sources as defined in rrd
  def data_sources
    self.info.keys.grep(/^ds\[/).map { |ds| ds[3..-1].split(']').first}.uniq
  end

end
