# Quit channel
#
# We can turn this around and tell Joe to stop
# when we're tired of listening to him.

def boring(message, quit)
  channel = Channel(String).new
  spawn do
    1.step(by: 1) do |i|
      sleep rand(1..1000)/1000.0

      select
      when quit.receive
        puts "quit"
        exit
      else
        channel.send("#{message} #{i}")
      end
    end
  end
  channel
end

def main
  quit_chan = Channel(Bool).new
  chan = boring("Ann", quit_chan)
  5.times do
    puts chan.receive
  end
  quit_chan.send(false)
end

main
