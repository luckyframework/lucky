class String
  def to_param : String
    self
  end

  # Returns a new string with whitespace and newlines squish to a single space.
  #
  # `String#squish` strips whitespace at the end of the string, and changes
  # consecutive whitespace groups into one space each. For example, it will
  # replace newlines with a single space and convert mutiple spaces to just one
  # space.
  def squish : String
    if ascii_only?
      squish_ascii
    else
      squish_unicode
    end
  end

  # Optimized for ASCII using String#ascii_whitespace?
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
