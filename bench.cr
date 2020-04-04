require "benchmark"

text = <<-TEXT
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua
TEXT

string_text = text * 40_000
io_text = IO::Memory.new(string_text)

Benchmark.ips do |x|
  x.report("string") do
    io = IO::Memory.new

    io.print(io_text.to_s)
  end
  x.report("io") do
    io = IO::Memory.new

    io.print(io_text)
  end
end
