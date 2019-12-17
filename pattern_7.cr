# Timeout for whole conversation using select

# Create the timer once, outside the loop, to time out the entire conversation.
# (In the previous program, we had a timeout for each message.)

def after(timeout : Int | Float)
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
  timeout = after(3)
  loop do
    select
    when msg = chan.receive
      puts msg
    when timeout.receive
      puts "You talk to much"
      exit
    end
  end
end

main
