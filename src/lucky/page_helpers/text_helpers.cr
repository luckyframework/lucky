# These helper methods will return a `String`.
module Lucky::TextHelpers
  @@_cycles = Hash(String, Cycle).new

  # Shorten text after a length point.
  #
  # Unlike `truncate`, this method can be used inside of other tags because it
  # returns a String. See `truncate` method for argument documentation.
  #
  # ```
  # link "#" do
  #   text truncate_text("Four score and seven years ago", length: 27)
  # end
  # ```
  # outputs:
  # ```html
  # <a href=\"#\">Four score and se...</a>
  # ```
  def truncate_text(text : String, length : Int32 = 30, omission : String = "...", separator : String | Nil = nil) : String
    return text unless text.size > length

    length_with_room_for_omission = length - omission.size
    stop = \
       if separator
         text.rindex(separator, length_with_room_for_omission) || length_with_room_for_omission
       else
         length_with_room_for_omission
       end

    "#{text[0, stop]}#{omission}"
  end

  # Grab a window of longer string
  #
  # You'll need to specify a `phrase` to center on, either a Regex or a String.
  #
  # Optionally:
  # * A `radius` (default: `100`) which controls how many units out from the
  # `phrase` on either side the excerpt will be.
  # * A `separator` (default `""`) which controls what the `radius` will count.
  # The unit by default is any character, which means the default is 100
  # character from the `phrase` in either direction. For example, an excerpt of # 10 words would use a `radius` of 10 and a `separator` of `" "`.
  # * An `omission` string (default: `"..."`), which prepends and appends to
  # the excerpt.
  #
  # ```
  # lyrics = "We represent the Lolly pop Guild, The Lolly pop Guild"
  # excerpt(text, phrase: "Guild", radius: 10)
  # ```
  # outputs:
  # ```html
  # ...Lolly pop Guild, The Loll...
  # ```
  def excerpt(text : String, phrase : Regex | String, separator : String = "", radius : Int32 = 100, omission : String = "...") : String
    if text.nil? || text.to_s.blank?
      return ""
    end

    case phrase
    when Regex
      regex = phrase
    else
      regex = /#{Regex.escape(phrase.to_s)}/i
    end

    return "" unless matches = text.match(regex)
    phrase = matches[0]

    unless separator.empty?
      text.split(separator).each do |value|
        if value.match(regex)
          phrase = value
          break
        end
      end
    end

    first_part, second_part = text.split(phrase, 2)

    prefix, first_part = cut_excerpt_part(:first, first_part, separator, radius, omission)
    postfix, second_part = cut_excerpt_part(:second, second_part, separator, radius, omission)

    affix = [first_part, separator, phrase, separator, second_part].join.strip
    [prefix, affix, postfix].join
  end

  # It pluralizes `singular` unless `count` is 1. You can specify the `plural` option
  # to override the chosen plural word.
  def pluralize(count : Int | String | Nil, singular : String, plural = nil) : String
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
             singular
           else
             plural || Wordsmith::Inflector.pluralize(singular)
           end

    "#{count || 0} #{word}"
  end

  def word_wrap(text : String, line_width : Int32 = 80, break_sequence : String = "\n") : String
    text = text.split("\n").map do |line|
      line.size > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1#{break_sequence}").strip : line
    end
    text.join(break_sequence)
  end

  # Creates a comma-separated sentence from the provided `Enumerable` *list*
  # and appends it to the view.
  #
  # #### Options:
  #
  # The following options allow you to specify how the sentence is constructed:
  #   - *word_connector* - A string used to join the elements in *list*s
  # containing three or more elements (Default is ", ")
  #   - *two_word_connector* - A string used to join the elements in *list*s
  # containing exactly two elements (Default is " and ")
  #   - *last_word_connector* - A string used to join the last element in
  # *list*s containing three or more elements (Default is ", and ")
  #
  # #### Examples:
  #
  #     to_sentence([] of String)            # => ""
  #     to_sentence([1])                     # => "1"
  #     to_sentence(["one", "two"])          # => "one and two"
  #     to_sentence({"one", "two", "three"}) # => "one, two, and three"
  #
  #     to_sentence(["one", "two", "three"], word_connector: " + ")
  #     # => one + two, and three
  #
  #     to_sentence(Set{"a", "z"}, two_word_connector: " to ")
  #     # => a to z
  #
  #     to_sentence(1..3, last_word_connector: ", or ")
  #     # => 1, 2, or 3
  #
  # NOTE: By default `#to_sentence` will include a
  # [serial comma](https://en.wikipedia.org/wiki/Serial_comma). This can be
  # overridden like so:
  #
  #     to_sentence(["one", "two", "three"], last_word_connector: " and ")
  #     # => one, two and three
  def to_sentence(list : Enumerable,
                  word_connector : String = ", ",
                  two_word_connector : String = " and ",
                  last_word_connector : String = ", and ") : String
    list = list.to_a

    if list.size < 3
      return list.join(two_word_connector)
    end

    "#{list[0..-2].join(word_connector)}#{last_word_connector}#{list.last}"
  end

  private def normalize_values(values) : Array(String)
    string_values = Array(String).new
    values.each { |v| string_values << v.to_s }
    string_values
  end

  def cycle(values : Array, name = "default") : String
    values = normalize_values(values)
    cycle = get_cycle(name)
    unless cycle && cycle.values == values
      cycle = set_cycle(name, Cycle.new(values))
    end
    cycle.to_s
  end

  def cycle(*values, name : String = "default") : String
    values = normalize_values(values)
    cycle(values, name: name)
  end

  def current_cycle(name : String = "default") : String?
    cycle = get_cycle(name)
    cycle.current_value if cycle
  end

  def reset_cycle(name : String = "default") : Int32?
    cycle = get_cycle(name)
    cycle.reset if cycle
  end

  class Cycle
    @values : Array(String)
    getter :values
    @index = 0

    def initialize(*values)
      string_values = Array(String).new
      values.each { |v| string_values << v.to_s }
      @values = string_values
      reset
    end

    def initialize(values : Array(String))
      @values = Array(String).new
      @values = values
      reset
    end

    def reset : Int32
      @index = 0
    end

    def current_value : String
      @values[previous_index]?.to_s
    end

    def to_s
      value = @values[@index]?.to_s
      @index = next_index
      value
    end

    private def next_index : Int32
      step_index(1)
    end

    private def previous_index : Int32
      step_index(-1)
    end

    private def step_index(n : Int32) : Int32
      (@index + n) % @values.size
    end
  end

  def reset_cycles : Hash(String, Cycle)
    @@_cycles = Hash(String, Cycle).new
  end

  private def get_cycle(name : String) : Cycle?
    @@_cycles[name]?
  end

  private def set_cycle(name : String, cycle_object : Cycle) : Cycle
    @@_cycles[name] = cycle_object
  end

  private def cut_excerpt_part(part_position : Symbol, part : String | Nil, separator : String, radius : Int32, omission : String)
    return "", "" if part.nil?

    part = part.split(separator)
    part.delete("")
    affix = part.size > radius ? omission : ""

    part = if part_position == :first
             drop_index = [part.size - radius, 0].max
             part[drop_index..-1]
           else
             part.first(radius)
           end

    return affix, part.join(separator)
  end

  private def split_paragraphs(text : String)
    return Array(String).new if text.blank?

    text.to_s.gsub(/\r\n?/, "\n").split(/\n\n+/).map do |t|
      t.gsub(/([^\n]\n)(?=[^\n])/, "\\1<br >") || t
    end
  end
end
