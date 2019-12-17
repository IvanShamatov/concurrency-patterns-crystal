# Google Search: A fake framework
#
# We can simulate the search function,
# much as we simulated conversation before.
puts "Google Search: A fake framework"

class FakeWeb
  property :kind

  def initialize(@kind : String)
  end

  def results(query)
    sleep rand(1..100)/1000.0
    "#{kind} result for #{query}\n"
  end
end

def main
  google = FakeWeb.new("google")
  started = Time.local
  results = google.results("golang")
  elapsed = Time.local - started
  puts results
  puts elapsed
end

main

# Google Search 1.0
#
# The Google function takes a query and returns a slice of Results (which are just strings).
# Google invokes Web, Image, and Video searches serially,
# appending them to the results slice.
puts "\nGoogle Search 1.0"

def google(query)
  web = FakeWeb.new("web")
  results = web.results(query)
  images = FakeWeb.new("image")
  results = results + images.results(query)
  video = FakeWeb.new("video")
  results = results + video.results(query)
  results
end

def main
  started = Time.local
  results = google("golang")
  elapsed = Time.local - started
  puts results
  puts elapsed
end

main

# Google Search 2.0
#
# Run the Web, Image, and Video searches concurrently, and wait for all results.
# No locks. No condition variables. No callbacks.
puts "\nGoogle Search 2.0"

module Search
  @web = FakeWeb.new("web")
  @images = FakeWeb.new("image")
  @video = FakeWeb.new("video")

  def google(query)
    chan = Channel(String).new
    spawn { chan.send @web.results(query) }
    spawn { chan.send @images.results(query) }
    spawn { chan.send @video.results(query) }
    results = Array.new
    3.times do
      results << chan.receive
    end
    results
  end

  main
end

# Google Search 2.1
#
# Don't wait for slow servers. No locks.
# No condition variables. No callbacks.
puts "\nGoogle Search 2.1"

module Search
  def after(timeout : Float)
    channel = Channel(Bool).new
    spawn do
      sleep timeout
      channel.send(true)
    end
    channel
  end

  def google(query)
    chan = Channel(String).new

    spawn { chan.send @web.results(query) }
    spawn { chan.send @images.results(query) }
    spawn { chan.send @video.results(query) }

    results = Array.new
    timeout = after(0.08)

    3.times do
      select
      when msg = chan.receive
        results << msg
      when timeout.receive
        puts "timeout"
      end
    end
    results
  end

  main
end

# Google Search 3.0
#
# Reduce tail latency using replicated search servers.
puts "\nGoogle Search 3.0"

module Search3
  def after(timeout : Float)
    channel = Channel(Bool).new
    spawn do
      sleep timeout
      channel.send(true)
    end
    channel
  end

  def first(query, *replicas)
    chan = Channel(String).new
    replicas.each do |rep|
      spawn { chan.send rep.results(query) }
    end
    chan.receive
  end

  def google(query)
    web1 = FakeWeb.new("web")
    web2 = FakeWeb.new("web")
    images1 = FakeWeb.new("image")
    images2 = FakeWeb.new("image")
    video1 = FakeWeb.new("video")
    video2 = FakeWeb.new("video")

    chan = Channel(String).new
    spawn { chan.send first(query, web1, web2) }
    spawn { chan.send first(query, images1, images2) }
    spawn { chan.send first(query, video1, video2) }
    results = Array.new
    timeout = after(0.08)
    3.times do
      select
      when msg = chan.receive
        results << msg
      when timeout.receive
        puts "timeout"
      end
    end
    results
  end

  main
end
