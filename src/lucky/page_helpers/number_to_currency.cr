module Lucky::NumberToCurrency
  DEFAULT_PRECISION       = 2
  DEFAULT_UNIT            = "$"
  DEFAULT_SEPARATOR       = "."
  DEFAULT_DELIMITER       = ","
  DEFAULT_DELIMITER_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/
  DEFAULT_FORMAT          = "%u%n"

  def number_to_currency(value : Float | Int32 | String,
                         precision : Int32 = DEFAULT_PRECISION,
                         unit : String = DEFAULT_UNIT,
                         separator : String = DEFAULT_SEPARATOR,
                         delimiter : String = DEFAULT_DELIMITER,
                         delimiter_pattern : Regex = DEFAULT_DELIMITER_REGEX,
                         format : String = DEFAULT_FORMAT,
                         negative_format : String = DEFAULT_FORMAT) : String
    value = value.to_s

    if value.to_f.sign == -1
      format = negative_format if negative_format != DEFAULT_FORMAT
      value = value.to_f.abs.to_s
    end

    value = "%.#{precision}f" % value

    left, right = value.split(".")
    left = left.gsub(delimiter_pattern) do |digit_to_delimit|
      "#{digit_to_delimit}#{delimiter}"
    end

    number = "#{left}#{separator}#{right}"

    format.gsub("%n", number).gsub("%u", unit)
  end
end
