# Channels as a handle on a service
#
# Our boring function returns a channel that lets us
# communicate with the boring service it provides.
# We can have more instances of the service.

def boring(message)
  channel = Channel(String).new

  spawn do
    10.times do |i|
      channel.send "#{message} #{i}"
      sleep rand(1..1000)/1000.0
    end
  end
  channel
end

def main
  ann = boring("Ann")
  joe = boring("Joe")

  5.times do
    puts "#{joe.receive}"
    puts "#{ann.receive}"
  end

  puts "You are boring; I'm leaving"
end

main
