# Generator: function that returns a channel
#
# Channels are first-class values, just like strings or integers.

def boring(message)
  channel = Channel(String).new

  spawn do
    i = 0
    loop do
      i = i + 1
      channel.send "#{message} #{i}"
      sleep rand(1..1000)/1000.0
    end
  end
  channel
end


def main
  chan = boring("boring!")
  i = 0
  while i < 6
    i = i + 1
    puts "You say: #{chan.receive}"
  end

  puts "You are boring; I'm leaving"
end

main
