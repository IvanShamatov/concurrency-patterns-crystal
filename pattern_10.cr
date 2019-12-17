# Daisy-chain

def wire(first, last)
  spawn do
    get = first.receive
    last.send(get + 1)
  end
end

def main
  arr = [Channel(Int32).new]
  1_000_000.times do
    first = Channel(Int32).new
    wire(arr.last, first)
    arr << first
  end

  spawn do
    arr.first.send 1
  end
  puts arr.last.receive
end

main
