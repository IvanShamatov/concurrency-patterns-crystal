# Multiplexing
#
# These programs make Joe and Ann count in lockstep.
# We can instead use a fan-in function to let whosoever is ready talk.

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


def fan_in(input1, input2)
  chan = Channel(String).new

  spawn { loop { chan.send input1.receive} }
  spawn { loop { chan.send input2.receive} }
  chan
end


def main
  chan = fan_in( boring("Ann"), boring("Joe") )

  10.times do |i|
    puts "#{chan.receive}"
  end

  puts "You are boring; I'm leaving"
end

main
