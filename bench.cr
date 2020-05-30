require "benchmark"

class String
  # Original
  def squish_regex : String
    gsub(/[[:space:]]+/, " ").strip
  end

  def squish_new : String
    if ascii_only?
      squish_ascii
    else
      squish_unicode
    end
  end

  def squish_simplified : String
    squish_unicode
  end

  private def squish_ascii : String
    String.build(size) do |str|
      print_blank = false
      each_char do |chr|
        if chr.ascii_whitespace?
          if print_blank
            str << ' '
            print_blank = false
          end
        else
          print_blank = true
          str << chr
        end
      end
    end.strip
  end

  private def squish_unicode : String
    String.build(size) do |str|
      print_blank = false
      each_char do |chr|
        if chr.whitespace?
          if print_blank
            str << ' '
            print_blank = false
          end
        else
          print_blank = true
          str << chr
        end
      end
    end.strip
  end
end

puts "Sanity check the return output is consistent:"
example = " f f\u00A0\u00A0\u00A0f f \n \t \v\v \f\f 11111  a l0* あ\u00A0\u00A0\u00A0 "
puts "String to squish " + example.inspect
puts "regex: " + example.squish_regex.inspect
puts "new: " + example.squish_new.inspect
puts "simplified: " + example.squish_simplified.inspect

# Original regex doesn't seem to work correctly with trailing unicode
if example.squish_regex != example.squish_new
  puts "WARN: regex version does not match:"
  puts "Regex:  #{example.squish_regex.inspect}".ljust(50)
  puts "Ours:  #{example.squish_new.inspect}".ljust(50)
end

puts
puts "Benchmarking String#squish ..."
puts
example = " f f f f \n \t\r\r   11111  a l0* " * 20
Benchmark.ips(warmup: 5, calculation: 10) do |x|
  x.report("squish regex ascii-only whitespace (#{example.bytesize} bytes)") { example.squish_regex }
  x.report("squish optimized ascii-only whitespace (#{example.bytesize} bytes)") { example.squish_new }
  x.report("squish simplified ascii-only whitespace (#{example.bytesize} bytes)") { example.squish_simplified }
end

puts
example = "あ\u00A0あ\u00A0\u00A0 \t  z  \n \r \r \t \v \f zzzz XXX  asdf    k ; ;, \u1680\u1680 " * 10
Benchmark.ips(warmup: 5, calculation: 10) do |x|
  x.report("squish regex w/ unicode whitespace (#{example.bytesize} bytes)") { example.squish_regex }
  x.report("squish optimized w/ unicode whitespace (#{example.bytesize} bytes)") { example.squish_new }
  x.report("squish simplified w/ unicode whitespace (#{example.bytesize} bytes)") { example.squish_simplified }
end
