# Restoring sequencing

# Send a channel on a channel, making spawnroutine wait its turn.
# Receive all messages, then enable them again by sending on a private channel.
# First we define a message type that contains a channel for the reply.
struct Message
  property body, wait_channel

  def initialize(@body : String, @wait_channel : Channel(Bool))
  end
end

def boring(message)
  channel = Channel(Message).new
  wait_channel = Channel(Bool).new

  spawn do
    1.step(by: 1) do |i|
      channel.send Message.new("#{message} #{i}", wait_channel)
      sleep rand(1..1000)/1000.0
      wait_channel.receive
    end
  end
  channel
end

def fan_in(input1, input2)
  chan = Channel(Message).new
  spawn { loop { chan.send input1.receive } }
  spawn { loop { chan.send input2.receive } }
  chan
end

def main
  chan = fan_in(boring("Ann"), boring("Joe"))

  5.times do |i|
    message1 = chan.receive
    puts message1.body
    message2 = chan.receive
    puts message2.body
    message1.wait_channel.send(true)
    message2.wait_channel.send(true)
  end

  puts "You are boring; I'm leaving"
end

main
