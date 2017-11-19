module LuckyWeb::PageHelpers
  DEFAULT_PRECISION       = 2
  DEFAULT_UNIT            = "$"
  DEFAULT_SEPARATOR       = "."
  DEFAULT_DELIMITER       = ","
  DEFAULT_DELIMITER_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/
  DEFAULT_FORMAT          = "%u%n"

  def number_to_currency(value : Nil)
  end

  def number_to_currency(value : Float | Int32, precision : Int32 = DEFAULT_PRECISION, unit : String = DEFAULT_UNIT, separator : String = DEFAULT_SEPARATOR, delimiter : String = DEFAULT_DELIMITER, delimiter_pattern : Regex = DEFAULT_DELIMITER_REGEX, format : String = DEFAULT_FORMAT)
    number_to_currency(value.to_s, precision: precision, unit: unit, separator: separator, delimiter: delimiter, delimiter_pattern: delimiter_pattern)
  end

  def number_to_currency(value : String, precision : Int32 = DEFAULT_PRECISION, unit : String = DEFAULT_UNIT, separator : String = DEFAULT_SEPARATOR, delimiter : String = DEFAULT_DELIMITER, delimiter_pattern : Regex = DEFAULT_DELIMITER_REGEX, format : String = DEFAULT_FORMAT)
    value = "%.#{precision}f" % value

    left, right = value.split(".")
    left = left.gsub(delimiter_pattern) do |digit_to_delimit|
      "#{digit_to_delimit}#{delimiter}"
    end

    number = "#{left}#{separator}#{right}"

    format.gsub("%n", number).gsub("%u", unit)
  end
end
