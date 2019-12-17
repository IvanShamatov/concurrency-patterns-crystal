# Timeout using select

# The time.After function returns a channel that blocks for the specified duration.
# After the interval, the channel delivers the current time, once.

def after(timeout : Float)
  channel = Channel(Bool).new
  spawn do
    sleep timeout
    channel.send(true)
  end
  channel
end

def boring(message)
  channel = Channel(String).new
  spawn do
    0.step(by: 1) do |i|
      sleep_time = rand(1..1000)/1000.0
      channel.send "#{message} #{i}: #{sleep_time}"
      sleep sleep_time
    end
  end
  channel
end

def main
  chan = boring("Ann")
  loop do
    select
    when msg = chan.receive
      puts msg
    when after(0.9).receive
      puts "You are to slow"
      exit
    end
  end
end

main
