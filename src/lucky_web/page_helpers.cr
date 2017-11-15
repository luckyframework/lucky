module LuckyWeb::PageHelpers
  DEFAULT_PRECISION       = 2
  DEFAULT_UNIT            = "$"
  DEFAULT_SEPARATOR       = "."
  DEFAULT_DELIMITER       = ","
  DEFAULT_DELIMITER_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

  def number_to_currency(value : Float, **options)
    number_to_currency(value.to_s, **options)
  end

  def number_to_currency(value : String, **options)
    precision = options.fetch(:precision, DEFAULT_PRECISION)
    unit = options.fetch(:unit, DEFAULT_UNIT)
    separator = options.fetch(:separator, DEFAULT_SEPARATOR)
    delimiter = options.fetch(:delimiter, DEFAULT_DELIMITER)

    value = "%.#{precision}f" % value

    left, right = value.split(".")
    left = left.gsub(DEFAULT_DELIMITER_REGEX) do |digit_to_delimit|
      "#{digit_to_delimit}#{delimiter}"
    end

    "#{unit}#{left}#{separator}#{right}"
  end
end
