# Select
#
# The select statement provides another way to handle multiple channels.
# It's like a switch, but each case is a communication:
# - All channels are evaluated.
# - Selection blocks until one communication can proceed, which then does.
# - If multiple can proceed, select chooses pseudo-randomly.
# - A default clause, if present, executes immediately if no channel is ready.

def boring(message)
  channel = Channel(String).new
  spawn do
    0.step(by: 1) do |i|
      channel.send "#{message} #{i}"
      sleep rand(1..1000)/1000.0
    end
  end
  channel
end

# Fan-in using select
# Rewrite our original fanIn function. Only one spawnroutine is needed. New:

def fan_in(input1, input2)
  chan = Channel(String).new
  spawn do
    loop do
      select
      when msg = input1.receive
        chan.send msg
      when msg = input2.receive
        chan.send msg
      end
    end
  end
  chan
end

def main
  chan = fan_in(boring("Ann"), boring("Joe"))

  10.times do |i|
    puts "#{chan.receive}"
  end

  puts "You are boring; I'm leaving"
end

main
