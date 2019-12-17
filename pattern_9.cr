# Receive on quit channel
#
# How do we know it's finished?
# Wait for it to tell us it's done: receive on the quit channel

def boring(message, quit)
  channel = Channel(String).new
  spawn do
    1.step(by: 1) do |i|
      sleep rand(1..1000)/1000.0

      select
      when quit.receive
        cleanup
        quit.send("See ya!")
      else
        channel.send("#{message} #{i}")
      end
    end
  end
  channel
end

def cleanup
  puts "Cleaning up"
end

def main
  quit_chan = Channel(String).new
  chan = boring("Joe", quit_chan)
  5.times do
    puts chan.receive
  end
  quit_chan.send("Bye")
  puts "Joe says #{quit_chan.receive}"
end

main
